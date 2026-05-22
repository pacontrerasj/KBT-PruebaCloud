module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.networking.vpc_id
}

module "database" {
  source       = "../../modules/database"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  db_subnets   = module.networking.private_subnets_data
  rds_sg_id    = module.security.rds_sg_id
  db_password  = var.db_password
}

module "loadbalancer" {
  source         = "../../modules/loadbalancer"
  project_name   = var.project_name
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnets
  alb_sg_id      = module.security.alb_sg_id
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
}

module "compute" {
  source           = "../../modules/compute"
  project_name     = var.project_name
  vpc_id           = module.networking.vpc_id
  private_subnets  = module.networking.private_subnets_app
  target_group_arn = module.loadbalancer.target_group_arn
  ec2_sg_id        = module.security.ec2_sg_id
  ami_id           = var.ami_id
  app_version      = var.app_version
}

module "monitoring" {
  source         = "../../modules/monitoring"
  project_name   = var.project_name
  asg_name       = module.compute.asg_name
  alb_arn_suffix = module.loadbalancer.alb_arn_suffix
  db_identifier  = module.database.db_identifier
  email_sns      = var.email_sns
  instance_ids   = module.compute.instance_ids
}

# Backup module disabled - AWS Academy doesn't support IAM roles
# module "backup" {
#   source           = "../../modules/backup"
#   project_name     = var.project_name
#   ec2_instance_ids = module.compute.instance_ids
#   rds_db_arn       = module.database.db_arn
# }