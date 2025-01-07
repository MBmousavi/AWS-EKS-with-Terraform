# Get the AZ in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to dynamically fetch AWS account ID
data "aws_caller_identity" "current" {}

# Fetch the database secret using the ARN
data "aws_secretsmanager_secret" "rds_secret" {
  arn = module.db.db_instance_master_user_secret_arn
}

# Get the latest version of the database secret
data "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

# Find the ALB created by AWS Load Balancer Controller
data "aws_lb" "ingress_alb" {
  name = "My-alb"
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_eks_addon_version" "s3_csi" {
  addon_name         = "aws-mountpoint-s3-csi-driver"
  kubernetes_version = data.aws_eks_cluster.eks_cluster.version
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_roles" "node_group_roles" {
  name_regex = "^nodes-eks-node-group-.*"
}