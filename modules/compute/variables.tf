variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "private_app_subnet_ids" {
  description = "IDs of the private subnets for application servers"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "ID of the application security group"
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name"
  default     = "" # Optional
}

variable "min_size" {
  description = "Minimum size of the ASG"
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the ASG"
  default     = 5
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  default     = 2
}

variable "db_endpoint" {
  description = "RDS endpoint"
}

variable "redis_endpoint" {
  description = "Redis endpoint"
}
