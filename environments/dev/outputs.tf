output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = module.networking.private_db_subnet_ids
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = module.security.app_security_group_id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = module.security.db_security_group_id
}

output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = module.security.redis_security_group_id
}

output "db_instance_endpoint" {
  description = "Connection endpoint for the database"
  value       = module.database.db_instance_endpoint
}

output "db_instance_name" {
  description = "Database name"
  value       = module.database.db_instance_name
}

output "redis_endpoint" {
  description = "Connection endpoint for Redis"
  value       = module.cache.redis_endpoint
}

output "media_bucket_name" {
  description = "Name of the media bucket"
  value       = module.storage.media_bucket_name
}

output "static_bucket_name" {
  description = "Name of the static assets bucket"
  value       = module.storage.static_bucket_name
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.loadbalancer.alb_dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "static_cdn_domain_name" {
  description = "Domain name of the static assets CloudFront distribution"
  value       = module.cdn.static_cdn_domain_name
}

output "media_cdn_domain_name" {
  description = "Domain name of the media files CloudFront distribution"
  value       = module.cdn.media_cdn_domain_name
}

output "app_url" {
  description = "URL for the main application"
  value       = module.dns.app_url
}

output "static_url" {
  description = "URL for static assets"
  value       = module.dns.static_url
}

output "media_url" {
  description = "URL for media files"
  value       = module.dns.media_url
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.monitoring.log_group_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}
