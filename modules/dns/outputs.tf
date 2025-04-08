# Output values
output "app_url" {
  value = "https://${aws_route53_record.app.name}"
}

output "static_url" {
  value = "https://${aws_route53_record.static.name}"
}

output "media_url" {
  value = "https://${aws_route53_record.media.name}"
}
