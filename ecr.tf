# Create image registry
module "ecr" {
  source                          = "terraform-aws-modules/ecr/aws"
  version                         = "2.3.0"
  repository_image_tag_mutability = "MUTABLE"
  repository_name                 = var.ecr_name

  # Grant access to EKS cluster and personal AWS account
  repository_read_write_access_arns = [
    module.eks.cluster_iam_role_arn,                                   # EKS cluster IAM role
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" # Personal AWS account
  ]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}