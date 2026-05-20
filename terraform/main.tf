module "networking" {
  source   = "./modules/networking"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

module "database" {
  source             = "./modules/database"
  vpc_id             = module.networking.vpc_id
  db_subnets         = module.networking.private_subnets
  rds_sg_id          = module.security.rds_sg_id
  db_password        = var.db_password
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.networking.vpc_id
  public_subnets     = module.networking.public_subnets
  private_subnets    = module.networking.private_subnets
  alb_sg_id          = module.security.alb_sg_id
  ec2_sg_id          = module.security.ec2_sg_id
  ami_id             = var.ami_id
  lab_role_arn       = var.lab_role_arn
}

module "monitoring" {
  source             = "./modules/monitoring"
  asg_name           = module.compute.asg_name
  alb_arn_suffix     = module.compute.alb_arn_suffix
  db_identifier      = module.database.db_identifier
  email_sns          = var.email_sns
}

module "backup" {
  source       = "./modules/backup"
  lab_role_arn = var.lab_role_arn
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.networking.vpc_id
}

output "db_endpoint" {
  description = "Endpoint de RDS MySQL"
  value       = module.database.db_endpoint
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = module.compute.asg_name
}