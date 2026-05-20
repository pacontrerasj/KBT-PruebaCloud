resource "aws_kms_key" "backup" {
  description             = "KMS key for backup vault"
  deletion_window_in_days = 7
  enable_key_rotation    = true

  tags = { Name = "${var.project_name}-backup-kms" }
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${var.project_name}-backup-kms"
  target_key_id = aws_kms_key.backup.key_id
}

resource "aws_backup_plan" "daily" {
  name = "${var.project_name}-backup-plan"

  rule {
    name             = "daily-backup"
    schedule         = "cron(0 5 ? * * *)"
    target_vault_name = aws_backup_vault.main.name
    start_window     = 60
    completion_window = 180

    lifecycle {
      cold_storage_after = 0
      delete_after       = 7
    }
  }

  tags = { Name = "${var.project_name}-backup-plan" }
}

resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn
  tags        = { Name = "${var.project_name}-backup-vault" }
}

resource "aws_backup_selection" "ec2" {
  name         = "${var.project_name}-ec2-selection"
  plan_id      = aws_backup_plan.daily.id
  vault_arn    = aws_backup_vault.main.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }

  resource_type = ["EC2"]
}

resource "aws_backup_selection" "rds" {
  count        = var.rds_db_arn != "" ? 1 : 0
  name         = "${var.project_name}-rds-selection"
  plan_id      = aws_backup_plan.daily.id
  vault_arn    = aws_backup_vault.main.arn
  resources    = [var.rds_db_arn]

  resource_type = ["RDS"]
}