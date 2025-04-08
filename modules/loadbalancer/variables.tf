variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets for ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  default     = "" # Optional, will create HTTP listener if not provided
}

variable "domain_name" {
  description = "Domain name for the chat application"
  default     = "" # Optional
}

