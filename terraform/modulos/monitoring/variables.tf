variable "asg_name" {
  description = "Nombre del Auto Scaling Group"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix del ALB"
  type        = string
}

variable "db_identifier" {
  description = "Identificador de la base de datos RDS"
  type        = string
}

variable "email_sns" {
  description = "Correo para notificaciones SNS"
  type        = string
}