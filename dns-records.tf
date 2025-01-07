# adding dns record for the domian
resource "aws_route53_record" "alb_cname_record" {
  zone_id = module.zones.route53_zone_zone_id[var.domain_name]
  name    = "adios.${var.domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_lb.ingress_alb.dns_name]
}