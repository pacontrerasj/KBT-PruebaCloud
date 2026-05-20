resource "aws_lb" "web_alb" {
  name               = "technova-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "web_tg" {
  name     = "technova-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_launch_template" "web_lt" {
  name          = "technova-lt"
  image_id      = var.ami_id
  instance_type = "t3.small"

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  network_interfaces {
    security_groups             = [var.ec2_sg_id]
    associate_public_ip_address = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y docker wget

systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c default

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

mkdir -p /home/ec2-user/app
cat <<HTML > /home/ec2-user/app/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>TechNova Solutions</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background-color: #f4f4f9; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0px 0px 10px rgba(0,0,0,0.1); display: inline-block; }
        h1 { color: #2c3e50; }
        .highlight { color: #e74c3c; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>TechNova Solutions</h1>
        <h2>Alta Disponibilidad Operativa</h2>
        <p>Atendido por la instancia EC2: <span class="highlight">$INSTANCE_ID</span></p>
        <p>Zona de Disponibilidad: <span class="highlight">$AZ</span></p>
    </div>
</body>
</html>
HTML

docker run -d -p 80:80 -v /home/ec2-user/app:/usr/share/nginx/html --name technova-web --restart always nginx:latest
EOF
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "technova-asg"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2
  target_group_arns   = [aws_lb_target_group.web_tg.arn]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
}