# Create the IAM user for github user
resource "aws_iam_user" "github_cicd_user" {
  name = "github"
}

# Create access keys for the IAM user
resource "aws_iam_access_key" "github_cicd_user" {
  user = aws_iam_user.github_cicd_user.name
}

# Define a policy for ECR access
resource "aws_iam_policy" "ecr_access_policy" {
  name        = "GitHub-ECR-Policy"
  description = "Policy to allow GitHub CICD user to access ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages"
        ],
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_name}"

      },
      {
        Effect = "Allow",
        Action = [
          "sts:GetCallerIdentity"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM user
resource "aws_iam_user_policy_attachment" "ecr_policy_attachment" {
  user       = aws_iam_user.github_cicd_user.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}



# Grant access to github user for updating images in EKS

resource "aws_iam_policy" "eks_access_policy" {
  name        = "eks-access-policy"
  description = "Policy for GitHub user to access EKS and update deployments"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_github_policy" {
  user       = aws_iam_user.github_cicd_user.name
  policy_arn = aws_iam_policy.eks_access_policy.arn
}

# Kubernetes configuration for GitHub user
resource "kubernetes_service_account" "github" {
  metadata {
    name      = "github"
    namespace = "default"
  }
}

resource "kubernetes_role" "deployment_editor" {
  metadata {
    name      = "deployment-editor"
    namespace = "default"
  }

  rule {
    api_groups = ["*"]
    resources  = ["deployments"]
    verbs      = ["get", "update", "patch"]
  }
}

resource "kubernetes_role_binding" "github_binding" {
  metadata {
    name      = "github-binding"
    namespace = "default"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.github.metadata[0].name
    namespace = kubernetes_service_account.github.metadata[0].namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.deployment_editor.metadata[0].name
  }
}

# First run: terraform import kubernetes_config_map.aws_auth kube-system/aws-auth
# Run this to import existing awss-auth file configmap. then we add github user to it.
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [module.eks]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      # Retain existing role mappings here (if any)
    ])
    mapUsers = jsonencode([
      # Add the new github user mapping
      {
        userarn  = aws_iam_user.github_cicd_user.arn
        username = "github"
        groups   = ["system:masters"] # Adjust permissions as needed
      }
    ])
  }
}