# create the Route53 hosted zone for our domian
module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 4.0"

  zones = {
    "${var.domain_name}" = {
    }
  }
}

# Generating SSL for https
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.1.1"

  domain_name = var.domain_name
  zone_id     = module.zones.route53_zone_zone_id[var.domain_name]

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]
  wait_for_validation = true
}