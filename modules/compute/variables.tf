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
  description = "ID de la AMI personalizada"
  type        = string
}

variable "app_version" {
  description = "Versión de la aplicación"
  type        = string
  default     = "v1.0.0"
}