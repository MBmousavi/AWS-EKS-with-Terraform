module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform_vpc"
  cidr = var.cidr

  azs              = data.aws_availability_zones.available.names
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  intra_subnets    = var.intra_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group = true

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
