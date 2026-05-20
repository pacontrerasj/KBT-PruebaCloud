resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "technova-db-subnet-group"
  subnet_ids = var.db_subnets
}

resource "aws_db_instance" "mysql" {
  identifier             = "technovadb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.small"
  allocated_storage      = 50
  storage_type           = "gp3"
  storage_encrypted      = true
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az               = false
  skip_final_snapshot    = true
  backup_retention_period = 7
}