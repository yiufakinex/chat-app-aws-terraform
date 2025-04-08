# Output values
output "media_bucket_name" {
  value = aws_s3_bucket.chat_media.bucket
}

output "media_bucket_arn" {
  value = aws_s3_bucket.chat_media.arn
}

output "media_bucket_domain_name" {
  value = aws_s3_bucket.chat_media.bucket_domain_name
}

output "static_bucket_name" {
  value = aws_s3_bucket.chat_static.bucket
}

output "static_bucket_arn" {
  value = aws_s3_bucket.chat_static.arn
}

output "static_bucket_domain_name" {
  value = aws_s3_bucket.chat_static.bucket_domain_name
}
