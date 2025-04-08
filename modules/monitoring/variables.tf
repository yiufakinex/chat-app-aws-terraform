variable "environment" {
  description = "Environment name"
  default     = "dev"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  default     = "chat-app"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB"
  type        = string
}

variable "db_instance_id" {
  description = "Identifier of the RDS instance"
  type        = string
}

variable "redis_cluster_id" {
  description = "Identifier of the Redis cluster"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  default     = 30
  type        = number
}

variable "alarm_evaluation_periods" {
  description = "Number of evaluation periods for alarms"
  default     = 2
  type        = number
}

variable "rds_cpu_threshold" {
  description = "CPU threshold for RDS alarm"
  default     = 80
  type        = number
}

variable "redis_cpu_threshold" {
  description = "CPU threshold for Redis alarm"
  default     = 80
  type        = number
}

variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5XX errors"
  default     = 10
  type        = number
}

variable "message_rate_threshold" {
  description = "Threshold for message rate alarm"
  default     = 1000
  type        = number
}

variable "alert_email" {
  description = "Email address for alerts"
  default     = "alerts@example.com"
  type        = string
}

variable "metric_period" {
  description = "Period for CloudWatch metrics in seconds"
  default     = 300
  type        = number
}
