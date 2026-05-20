output "db_endpoint" {
  description = "Endpoint de RDS MySQL"
  value       = aws_db_instance.mysql.endpoint
}

output "db_identifier" {
  description = "Identificador de la base de datos"
  value       = aws_db_instance.mysql.identifier
}

output "db_arn" {
  description = "ARN de la base de datos"
  value       = aws_db_instance.mysql.arn
}

output "db_port" {
  description = "Puerto de la base de datos"
  value       = aws_db_instance.mysql.port
}