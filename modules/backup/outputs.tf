output "backup_plan_arn" {
  description = "ARN del plan de backup"
  value       = aws_backup_plan.daily.arn
}

output "backup_vault_name" {
  description = "Nombre del vault de backup"
  value       = aws_backup_vault.main.name
}