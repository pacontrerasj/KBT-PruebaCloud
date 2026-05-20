output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB"
  value       = aws_lb.web_alb.arn_suffix
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}