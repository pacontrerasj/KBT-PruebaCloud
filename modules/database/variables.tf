variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "db_subnets" {
  description = "IDs de las subredes privadas para RDS"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "ID del Security Group de RDS"
  type        = string
}

variable "db_password" {
  description = "Contraseña para RDS MySQL"
  type        = string
  sensitive   = true
  default     = null
}