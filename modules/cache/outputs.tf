# Output values
output "redis_endpoint" {
  value = "${aws_elasticache_cluster.chat_redis.cache_nodes.0.address}:${aws_elasticache_cluster.chat_redis.cache_nodes.0.port}"
}

output "redis_port" {
  value = aws_elasticache_cluster.chat_redis.cache_nodes.0.port
}
