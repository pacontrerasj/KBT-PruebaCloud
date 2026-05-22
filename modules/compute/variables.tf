variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "private_subnets" {
  description = "IDs de las subredes privadas"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN del Target Group del ALB"
  type        = string
}

variable "ec2_sg_id" {
  description = "ID del Security Group de EC2"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI personalizada (opcional, usará Amazon Linux 2 si está vacío)"
  type        = string
  default     = ""
}

variable "app_version" {
  description = "Versión de la aplicación"
  type        = string
  default     = "v1.0.0"
}