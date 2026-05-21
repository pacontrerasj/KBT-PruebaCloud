output "asg_name" {
  description = "Nombre del ASG"
  value       = aws_autoscaling_group.web.name
}

output "launch_template_id" {
  description = "ID del Launch Template"
  value       = aws_launch_template.web.id
}

output "instance_ids" {
  description = "IDs de las instancias del ASG"
  value       = []
}