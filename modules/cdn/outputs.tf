# Output values
output "static_cdn_domain_name" {
  value = aws_cloudfront_distribution.static.domain_name
}

output "static_cdn_id" {
  value = aws_cloudfront_distribution.static.id
}

output "media_cdn_domain_name" {
  value = aws_cloudfront_distribution.media.domain_name
}

output "media_cdn_id" {
  value = aws_cloudfront_distribution.media.id
}
