variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "ami_id" {
  description = "ID de la AMI creada a partir de la instancia actual t3.small"
  type        = string
  # REEMPLAZAR: Debes poner el ID de la AMI que creaste manualmente
}

variable "db_password" {
  description = "Contraseña para RDS MySQL"
  type        = string
  sensitive   = true
  # REEMPLAZAR: Configura esto mediante variables de entorno o tfvars
}

variable "lab_role_arn" {
  description = "ARN del LabRole de AWS Academy"
  type        = string
  # REEMPLAZAR: Pega aquí el ARN de tu LabRole (ej. arn:aws:iam::123456789012:role/LabRole)
}

variable "email_sns" {
  description = "Correo para notificaciones de CloudWatch"
  type        = string
  # REEMPLAZAR: Tu correo para recibir alertas
}