variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC para reglas de SSH"
  type        = string
  default     = "10.0.0.0/16"
}