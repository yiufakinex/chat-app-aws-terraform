# Output values
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

output "availability_zones" {
  value = var.availability_zones
}

