resource "aws_kms_key" "backup" {
  description             = "KMS key for backup vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = { Name = "${var.project_name}-backup-kms" }
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${var.project_name}-backup-kms"
  target_key_id = aws_kms_key.backup.key_id
}

resource "aws_backup_plan" "daily" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily-backup" # Nota: algunos usan "rule_name"
    schedule          = "cron(0 5 * * ? *)"
    target_vault_name = aws_backup_vault.main.name
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = 7
      # Opcionalmente:
      # cold_storage_after = 30
    }
  }

  tags = {
    Name = "${var.project_name}-backup-plan"
  }
}

# También necesitas el vault:
resource "aws_backup_vault" "main" {
  name = "${var.project_name}-backup-vault"

  tags = {
    Name = "${var.project_name}-backup-vault"
  }
}

resource "aws_backup_vault" "main" {
  name        = "${var.project_name}-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn
  tags        = { Name = "${var.project_name}-backup-vault" }
}