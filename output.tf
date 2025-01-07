output "azs" {
  description = "Availability Zones"
  value       = module.vpc.azs
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet ids"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet ids"
  value       = module.vpc.public_subnets
}

output "intra_subnets" {
  description = "Intra subnet ids"
  value       = module.vpc.intra_subnets
}

output "database_subnets" {
  description = "database subnet ids"
  value       = module.vpc.database_subnets
}

output "address" {
  value = module.db.db_instance_address
}

output "db_master_credentials_arn" {
  value     = module.db.db_instance_master_user_secret_arn
  sensitive = true

}

# Output the sensitive values
output "db_master_password" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
  sensitive = true
}

output "db_master_username" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
  sensitive = true
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "route53_zone_zone_id" {
  value = module.zones.route53_zone_zone_id
}

output "route53_zone_name_servers" {
  value = module.zones.route53_zone_name_servers
}

output "primary_name_server" {
  value = module.zones.primary_name_server
}

output "efs_fs_id" {
  value = module.efs.id
}

# Output the access keys for GitHub CI/CD integration
output "github_cicd_user_access_key" {
  value = aws_iam_access_key.github_cicd_user.id
}

output "github_cicd_user_secret_key" {
  value     = aws_iam_access_key.github_cicd_user.secret
  sensitive = true
}