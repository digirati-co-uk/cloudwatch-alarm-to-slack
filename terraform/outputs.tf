output "sns_topic_arn" {
  value       = aws_sns_topic.cloudwatch_alarm.arn
  description = "ARN of SNS topic"
}
