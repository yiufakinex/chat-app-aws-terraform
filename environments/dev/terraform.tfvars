# Required variables
db_password = "your-secure-password"

# Optional variables with default values
domain_name     = "chat-app.example.com"
certificate_arn = "arn:aws:acm:region:account-id:certificate/certificate-id"

# Environment-specific configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Database configuration
db_username       = "chatadmin"
db_instance_class = "db.t3.small"
multi_az          = false

# Cache configuration
redis_node_type = "cache.t3.small"

# Compute configuration
app_instance_type = "t3.small"
key_name          = "your-ssh-key-name"
min_size          = 1
max_size          = 3
desired_capacity  = 1

# Alerting
alert_email = "your-email@example.com"
