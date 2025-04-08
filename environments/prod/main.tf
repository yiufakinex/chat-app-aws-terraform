provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  environment        = var.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Security Module
module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id      = module.networking.vpc_id
  vpc_cidr    = "10.0.0.0/16"
}

# Database Module
module "database" {
  source = "../../modules/database"

  environment          = var.environment
  db_subnet_group_name = module.networking.db_subnet_group_name
  db_security_group_id = module.security.db_security_group_id
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = "db.r5.large"
  multi_az             = true # Enable high availability for production
}

# Cache Module (Redis)
module "cache" {
  source = "../../modules/cache"

  environment             = var.environment
  redis_security_group_id = module.security.redis_security_group_id
  redis_subnet_ids        = module.networking.private_app_subnet_ids
  redis_node_type         = "cache.m5.large"
}

# Storage Module (S3)
module "storage" {
  source = "../../modules/storage"

  environment = var.environment
}

# Load Balancer Module
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = var.certificate_arn
  domain_name           = var.domain_name
}

# Compute Module (EC2 & ASG)
module "compute" {
  source = "../../modules/compute"

  environment            = var.environment
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  app_security_group_id  = module.security.app_security_group_id
  target_group_arn       = module.loadbalancer.target_group_arn
  db_endpoint            = module.database.db_instance_endpoint
  redis_endpoint         = module.cache.redis_endpoint
  instance_type          = "t3.large"
  key_name               = "chat-app-key" # Replace with your SSH key name
  min_size               = 3
  max_size               = 10
  desired_capacity       = 3
}

# CDN Module (CloudFront)
module "cdn" {
  source = "../../modules/cdn"

  environment               = var.environment
  static_bucket_domain_name = module.storage.static_bucket_domain_name
  media_bucket_domain_name  = module.storage.media_bucket_domain_name
  certificate_arn           = var.certificate_arn
  domain_name               = var.domain_name
}

# DNS Module (Route53)
module "dns" {
  source = "../../modules/dns"

  environment            = var.environment
  domain_name            = var.domain_name
  alb_dns_name           = module.loadbalancer.alb_dns_name
  alb_zone_id            = module.loadbalancer.alb_zone_id
  static_cdn_domain_name = module.cdn.static_cdn_domain_name
  media_cdn_domain_name  = module.cdn.media_cdn_domain_name
}

# Monitoring Module (CloudWatch)
module "monitoring" {
  source = "../../modules/monitoring"

  environment      = var.environment
  app_name         = "chat-app"
  alb_arn_suffix   = replace(module.loadbalancer.alb_dns_name, ".*dualstack.", "")
  db_instance_id   = replace(module.database.db_instance_endpoint, ".*:", "")
  redis_cluster_id = replace(module.cache.redis_endpoint, ".*:", "")
  asg_name         = "${var.environment}-chat-app-asg"
}
