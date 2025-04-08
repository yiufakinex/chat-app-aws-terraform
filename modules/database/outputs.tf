# Output values
output "db_instance_endpoint" {
  description = "Connection endpoint for the database"
  value       = aws_db_instance.chat_db.endpoint
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.chat_db.db_name
}

output "db_instance_id" {
  description = "Database instance identifier"
  value       = aws_db_instance.chat_db.id
}

output "db_instance_username" {
  description = "Database master username"
  value       = aws_db_instance.chat_db.username
  sensitive   = true
}

output "db_instance_arn" {
  description = "ARN of the database instance"
  value       = aws_db_instance.chat_db.arn
}

output "db_parameter_group_name" {
  description = "Name of the database parameter group"
  value       = aws_db_parameter_group.chat_db.name
}
