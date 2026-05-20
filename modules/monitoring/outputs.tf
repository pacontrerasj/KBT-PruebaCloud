output "sns_topic_arn" {
  description = "ARN del topic SNS"
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  description = "Nombre del Dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}