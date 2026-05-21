output "asg_name" {
  description = "Nombre del ASG"
  value       = aws_autoscaling_group.web.name
}

output "launch_template_id" {
  description = "ID del Launch Template"
  value       = aws_launch_template.web.id
}

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.web.name]
  }
}

output "instance_ids" {
  description = "IDs de las instancias del ASG"
  value       = data.aws_instances.asg_instances.ids
}