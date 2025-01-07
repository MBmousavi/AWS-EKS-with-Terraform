![eks_terraform](https://github.com/user-attachments/assets/f919c7fe-62c3-4fb3-80e2-24495f35b24c)

In this practice scenario, we used Terraform to spin up different AWS resources to setup an EKS cluster and it's dependencies.

### 1- VPC:
A Terraform module was used to simplify the VPC setup, reducing the amount of Terraform codes.
The configuration includes multiple public and private subnets and a single NAT gateway.

### 2- Route 53:
AWS's official DNS service was used to host DNS records.

### 3- AWS ACM (Certificate Manager):
AWS ACM was used to generate SSL certificates.
SSL termination is handled outside the EKS cluster, at the Application Load Balancer (ALB) layer.

### 4- AWS EKS (Elastic Kubernetes Service):
A Terraform module was utilized to set up the EKS cluster.
Additional configurations include integration of CSI drivers for S3, EBS, and EFS storage.

### 5- User and Permissions:
IAM roles and policies were defined to grant EKS nodes access to EBS, EFS, and S3 services.

A GitHub user was created with permissions to:

Push container images to AWS ECR.

Update deployments within the EKS cluster.

### 6- AWS RDS (Relational Database Service):
A simple PostgreSQL database was provisioned using RDS.
Database credentials are securely managed via AWS KMS (Key Management Service).

### 7- ALB and Ingress:
In the `ingress-alb.yml` you see the yaml file for creating the ingress, when you apply it, it creates a ALB in the AWS.
