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

  user_data = base64encode(file("${path.module}/../user_data.sh"))
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