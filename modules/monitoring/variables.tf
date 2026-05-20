variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

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

variable "instance_ids" {
  description = "IDs de las instancias EC2"
  type        = list(string)
  default     = []
}