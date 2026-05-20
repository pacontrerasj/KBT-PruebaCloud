output "alb_dns_name" {
  description = "DNS del ALB"
  value       = aws_lb.web.dns_name
}

output "alb_arn" {
  description = "ARN del ALB"
  value       = aws_lb.web.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB"
  value       = aws_lb.web.arn_suffix
}

output "target_group_arn" {
  description = "ARN del Target Group"
  value       = aws_lb_target_group.web.arn
}