variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "technova"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "ID de la AMI personalizada"
  type        = string
}

variable "db_password" {
  description = "Contraseña para RDS MySQL"
  type        = string
  sensitive   = true
}

variable "email_sns" {
  description = "Correo para notificaciones SNS"
  type        = string
}

variable "app_version" {
  description = "Versión de la aplicación"
  type        = string
  default     = "v1.0.0"
}