# Redis subnet group
resource "aws_elasticache_subnet_group" "chat_redis" {
  name        = "${var.environment}-chat-redis-subnet-group"
  description = "Subnet group for Redis cache"
  subnet_ids  = var.redis_subnet_ids
}

# Redis parameter group
resource "aws_elasticache_parameter_group" "chat_redis" {
  name   = "${var.environment}-chat-redis-params"
  family = "redis6.x"

  # Configure Redis to be optimized for chat application
  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex" # Enable keyspace notifications for expired keys
  }
}

# Redis ElastiCache cluster for chat message broker and session management
resource "aws_elasticache_cluster" "chat_redis" {
  cluster_id           = "${var.environment}-chat-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.chat_redis.name
  subnet_group_name    = aws_elasticache_subnet_group.chat_redis.name
  security_group_ids   = [var.redis_security_group_id]

  port = 6379

  # Enable automatic failover for production
  # Note: For multiple nodes with automatic failover, use aws_elasticache_replication_group instead

  maintenance_window = "sun:05:00-sun:06:00"

  tags = {
    Name        = "${var.environment}-chat-redis"
    Environment = var.environment
  }
}
