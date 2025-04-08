variable "environment" {
  description = "Environment name"
  default     = "prod"
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
  # Required for production
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
  default     = "db.r5.large"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  default     = true # Enable high availability for production
  type        = bool
}

variable "redis_node_type" {
  description = "Node type for Redis"
  default     = "cache.m5.large"
  type        = string
}

variable "app_instance_type" {
  description = "EC2 instance type for application servers"
  default     = "t3.large"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  default     = "chat-app-key" # Replace with your SSH key name
  type        = string
}

variable "min_size" {
  description = "Minimum size of the ASG"
  default     = 3
  type        = number
}

variable "max_size" {
  description = "Maximum size of the ASG"
  default     = 10
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  default     = 3
  type        = number
}

variable "alert_email" {
  description = "Email address for alerts"
  default     = "alerts@example.com" # Replace with your email
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  default     = 90 # Longer retention for production
  type        = number
}

variable "backup_retention_period" {
  description = "Number of days to retain RDS backups"
  default     = 30 # Longer retention for production
  type        = number
}
