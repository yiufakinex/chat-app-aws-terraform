variable "environment" {
  description = "Environment name"
  default     = "staging"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  default     = "chat-app.example.com" # Replace with your domain
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  default     = "chatadmin"
  sensitive   = true
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  sensitive   = true
  type        = string
  # Set using environment variable TF_VAR_db_password or terraform.tfvars
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
  # Required for staging
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to use"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type        = list(string)
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  default     = "db.t3.medium" # Moderate size for staging
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  default     = true # Enable for staging to test HA setup
  type        = bool
}

variable "redis_node_type" {
  description = "Node type for Redis"
  default     = "cache.t3.medium" # Moderate size for staging
  type        = string
}

variable "app_instance_type" {
  description = "EC2 instance type for application servers"
  default     = "t3.medium" # Moderate size for staging
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  default     = "chat-app-key" # Replace with your SSH key name
  type        = string
}

variable "min_size" {
  description = "Minimum size of the ASG"
  default     = 2 # Moderate size for staging
  type        = number
}

variable "max_size" {
  description = "Maximum size of the ASG"
  default     = 6 # Moderate ceiling for staging
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  default     = 2 # Moderate size for staging
  type        = number
}

variable "alert_email" {
  description = "Email address for alerts"
  default     = "alerts@example.com" # Replace with your email
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  default     = 60 # Moderate retention for staging
  type        = number
}

variable "backup_retention_period" {
  description = "Number of days to retain RDS backups"
  default     = 14 # Moderate retention for staging
  type        = number
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Restrict to private IPs in staging
}
