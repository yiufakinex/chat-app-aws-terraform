variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

# Add this variable to handle the ssh_allowed_cidrs parameter
variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Consider restricting this in production
}

variable "app_port" {
  description = "Port the application runs on"
  type        = number
  default     = 8080
}
