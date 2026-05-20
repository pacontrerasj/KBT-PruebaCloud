variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "ec2_instance_ids" {
  description = "IDs de las instancias EC2 a respaldar"
  type        = list(string)
  default     = []
}

variable "rds_db_arn" {
  description = "ARN de la base de datos RDS"
  type        = string
  default     = ""
}