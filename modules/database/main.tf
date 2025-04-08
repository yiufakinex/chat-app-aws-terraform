# RDS PostgreSQL instance for chat application
resource "aws_db_instance" "chat_db" {
  identifier            = "${var.environment}-chat-db"
  engine                = "postgres"
  engine_version        = "13.7"
  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"

  db_name  = "chatapp" # Corrected parameter name for PostgreSQL
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]

  multi_az            = var.multi_az
  publicly_accessible = false

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.environment}-chat-db-final-snapshot"

  parameter_group_name = aws_db_parameter_group.chat_db.name

  tags = {
    Name        = "${var.environment}-chat-db"
    Environment = var.environment
  }
}

# Parameter group for PostgreSQL
resource "aws_db_parameter_group" "chat_db" {
  name   = "${var.environment}-chat-db-pg"
  family = "postgres13"

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "shared_buffers"
    value = "{DBInstanceClassMemory/32768}MB"
  }

  tags = {
    Name        = "${var.environment}-chat-db-pg"
    Environment = var.environment
  }
}
