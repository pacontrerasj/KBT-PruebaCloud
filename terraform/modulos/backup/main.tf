resource "aws_backup_vault" "vault" {
  name = "technova-vault"
}

resource "aws_backup_plan" "plan" {
  name = "technova-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(0 5 ? * * *)"
    lifecycle {
      delete_after = 14
    }
  }
}

resource "aws_backup_selection" "selection" {
  iam_role_arn = var.lab_role_arn
  name         = "technova-backup-selection"
  plan_id      = aws_backup_plan.plan.id

  resources = [
    "arn:aws:ec2:*:*:instance/*",
    "arn:aws:rds:*:*:db:*"
  ]
}