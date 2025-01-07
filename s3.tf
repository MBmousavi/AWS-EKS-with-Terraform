resource "aws_s3_bucket" "eks_s3_bucket" {
  bucket        = var.s3_bucket
  force_destroy = true
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${var.cluster_name}-s3-access-policy"
  description = "IAM policy for S3 access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "MountpointFullBucketAccess",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}"
        ],
      },
      {
        Sid    = "MountpointFullObjectAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}/*"
        ],
      },
    ],
  })
}

resource "aws_iam_role" "s3_role" {
  name = "${var.cluster_name}-s3-csi-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.this.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:s3-csi-driver-sa",
            "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com",
          },
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "s3_role_attachment" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.s3_role.name
}

resource "aws_eks_addon" "s3_csi" {
  cluster_name             = data.aws_eks_cluster.eks_cluster.id
  addon_name               = "aws-mountpoint-s3-csi-driver"
  addon_version            = data.aws_eks_addon_version.s3_csi.version
  service_account_role_arn = aws_iam_role.s3_role.arn
}


resource "aws_iam_role_policy_attachment" "node_group_s3_access" {
  for_each   = toset([for arn in data.aws_iam_roles.node_group_roles.arns : split("/", arn)[1]])
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = each.key
}