output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnets_app" {
  description = "IDs de las subredes privadas de aplicación"
  value       = aws_subnet.private_app[*].id
}

output "private_subnets_data" {
  description = "IDs de las subredes privadas de datos"
  value       = aws_subnet.private_data[*].id
}