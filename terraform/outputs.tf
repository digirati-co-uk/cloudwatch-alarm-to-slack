output "sns_topic_arn" {
  value       = aws_sns_topic.cloudwatch_alarm.arn
  description = "ARN of SNS topic"
}

output "role_name" {
  value       = aws_iam_role.cloudwatch_to_slack_exec_role.name
  description = "Name of Lambda role"
}