variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "static_bucket_domain_name" {
  description = "Domain name of the S3 bucket for static assets"
}

variable "media_bucket_domain_name" {
  description = "Domain name of the S3 bucket for media files"
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  default     = "" # Optional, no HTTPS if not provided
}

variable "domain_name" {
  description = "Domain name for the CDN"
  default     = "" # Optional
}
