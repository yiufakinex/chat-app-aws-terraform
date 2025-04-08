output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.chat_app.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.chat_app.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.chat_app.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.chat_app.latest_version
}

output "iam_role_name" {
  description = "Name of the IAM role assigned to instances"
  value       = aws_iam_role.chat_app_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role assigned to instances"
  value       = aws_iam_role.chat_app_role.arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.chat_app_profile.name
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = aws_autoscaling_policy.scale_down.arn
}

output "cpu_high_alarm_name" {
  description = "Name of the CPU high alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "cpu_low_alarm_name" {
  description = "Name of the CPU low alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_low.alarm_name
}
