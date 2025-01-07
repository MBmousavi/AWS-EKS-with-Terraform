# create security group for RDS
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "sg_rds"
  vpc_id = module.vpc.vpc_id

  # Ingress rule for PostgreSQL
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

# create AWS RDS
module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "6.10.0"
  identifier = "database"

  engine               = "postgres"
  engine_version       = "15.4"
  major_engine_version = "15"
  instance_class       = "db.t4g.micro" # Free tier compatible if eligible
  family               = "postgres15"

  allocated_storage = 20 # Minimum for free tier

  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true
  port                        = 5432

  multi_az               = false # Free tier only supports single AZ
  create_db_subnet_group = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled = false
  create_monitoring_role       = false

  tags = {
    Name        = "PostgreSQL-DB"
    Environment = "dev"
    Terraform   = "true"
  }
}
