variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "public_subnets" {
  description = "IDs de las subredes públicas"
  type        = list(string)
}

variable "private_subnets" {
  description = "IDs de las subredes privadas"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID del Security Group del ALB"
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

variable "lab_role_arn" {
  description = "ARN del LabRole de AWS Academy"
  type        = string
}