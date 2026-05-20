output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs de las subredes privadas"
  value       = aws_subnet.private[*].id
}