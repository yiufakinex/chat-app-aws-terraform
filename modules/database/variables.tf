variable "environment" {
  description = "Environment name"
  default     = "dev"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "db_security_group_id" {
  description = "ID of the database security group"
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
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  default     = "db.t3.small"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = true
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for the RDS instance in GB"
  type        = number
  default     = 100
}

variable "engine_version" {
  description = "Engine version for PostgreSQL"
  type        = string
  default     = "13.7"
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting the DB instance"
  type        = bool
  default     = false
}
