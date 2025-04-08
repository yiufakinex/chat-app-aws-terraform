variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "redis_security_group_id" {
  description = "ID of the Redis security group"
}

variable "redis_subnet_ids" {
  description = "IDs of the private subnets for Redis"
  type        = list(string)
}

variable "redis_node_type" {
  description = "Node type for Redis"
  default     = "cache.t3.small"
}
