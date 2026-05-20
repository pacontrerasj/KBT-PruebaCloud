output "backup_vault_arn" {
  description = "ARN del vault de backup"
  value       = aws_backup_vault.vault.arn
}

output "backup_plan_id" {
  description = "ID del plan de backup"
  value       = aws_backup_plan.plan.id
}