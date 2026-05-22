output "repository_url" {
  description = "URL del repositorio ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  description = "ARN del repositorio ECR"
  value       = aws_ecr_repository.app.arn
}