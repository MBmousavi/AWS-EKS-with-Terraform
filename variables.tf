variable "region" {
  description = "region"
  type        = string
}

variable "profile" {
  type        = string
  description = "AWS Profile"
}
variable "cidr" {
  description = "VPC CIDR Range"
  type        = string
}

variable "private_subnets" {
  description = "Subnet CIDRS"
  type        = list(string)
}

variable "public_subnets" {
  description = "Subnet CIDRS"
  type        = list(string)
}

variable "intra_subnets" {
  description = "Subnet CIDRS"
  type        = list(string)
}

variable "database_subnets" {
  description = "Subnet CIDRS"
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "domain_name" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "ecr_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}