output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = module.ecr.repository_url
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = module.loadbalancer.alb_dns_name
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.networking.vpc_id
}

output "db_endpoint" {
  description = "Endpoint de RDS MySQL"
  value       = module.database.db_endpoint
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = module.compute.asg_name
}

output "sns_topic_arn" {
  description = "ARN del topic SNS para alertas"
  value       = module.monitoring.sns_topic_arn
}

# Backup outputs commented - module disabled for AWS Academy
# output "backup_plan_arn" {
#   description = "ARN del plan de backup"
#   value       = module.backup.backup_plan_arn
# }