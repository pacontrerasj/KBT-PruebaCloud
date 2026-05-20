locals {
  user_data = <<-EOF
              #!/bin/bash
              cd /home/ec2-user

              # Install Docker
              yum update -y
              yum install -y docker

              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Install CloudWatch Agent
              wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
              rpm -U ./amazon-cloudwatch-agent.rpm

              # Get instance metadata
              TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
              INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
              AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

              # Create app directory
              mkdir -p /home/ec2-user/app

              # Create docker-compose.yml
              cat > /home/ec2-user/app/docker-compose.yml << 'COMPOSE'
              version: '3.8'
              services:
                web:
                  image: nginx:latest
                  ports:
                    - "80:80"
                  volumes:
                    - /home/ec2-user/app/html:/usr/share/nginx/html:ro
                  restart: always
                  healthcheck:
                    test: ["CMD", "curl", "-f", "http://localhost"]
                    interval: 30s
                    timeout: 10s
                    retries: 3
              COMPOSE

              # Create HTML content
              cat > /home/ec2-user/app/html/index.html << HTML
              <!DOCTYPE html>
              <html lang="es">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>TechNova Solutions - ${var.app_version}</title>
                  <style>
                      body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
                      .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); max-width: 500px; }
                      h1 { color: #2c3e50; margin-bottom: 10px; }
                      h2 { color: #764ba2; margin-top: 0; font-weight: 400; }
                      .info { background: #f8f9fa; padding: 20px; border-radius: 10px; margin-top: 20px; }
                      .info p { margin: 10px 0; color: #555; }
                      .highlight { color: #764ba2; font-weight: bold; }
                      .version { color: #999; font-size: 12px; margin-top: 20px; }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>TechNova Solutions</h1>
                      <h2>Alta Disponibilidad</h2>
                      <div class="info">
                          <p>Instancia: <span class="highlight">$INSTANCE_ID</span></p>
                          <p>Zona: <span class="highlight">$AZ</span></p>
                          <p>Región: <span class="highlight">us-east-1</span></p>
                      </div>
                      <p class="version">Versión: ${var.app_version}</p>
                  </div>
              </body>
              </html>
              HTML

              # Start application
              cd /home/ec2-user/app
              docker-compose up -d

              # Configure CloudWatch Agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
              EOF
}

resource "aws_launch_template" "web" {
  name          = "${var.project_name}-lt"
  image_id      = var.ami_id
  instance_type = "t3.small"

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  network_interfaces {
    security_groups             = [var.ec2_sg_id]
    associate_public_ip_address = false
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(local.user_data)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tags = { Name = "${var.project_name}-lt" }
}

resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}