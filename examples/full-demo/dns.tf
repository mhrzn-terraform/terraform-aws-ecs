resource "aws_route53_record" "dns" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${local.env_prefix_dash}${var.hostname}"
  type    = "A"

  alias {
    name                   = module.nginx.lb_dns_name
    zone_id                = module.nginx.lb_zone_id
    evaluate_target_health = false
  }
}
