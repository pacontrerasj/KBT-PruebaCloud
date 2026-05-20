output "db_identifier" {
  description = "Identificador de la base de datos RDS"
  value       = aws_db_instance.mysql.identifier
}

output "db_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = aws_db_instance.mysql.endpoint
}