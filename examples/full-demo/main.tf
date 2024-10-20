data "aws_caller_identity" "current" {}

data "aws_route53_zone" "zone" {
  name = var.zone
}

data "aws_acm_certificate" "wildcard_acm" {
  domain   = "*.${var.zone}"
  statuses = ["ISSUED"]
}

locals {
  env_suffix_dash = var.env == "prod" ? "" : "-${var.env}"
  env_prefix_dash = var.env == "prod" ? "" : "${var.env}-"
}

module "service" {
  source                              = "mhrzn-terraform/ecs/aws"
  version                             = "1.0.8"
  env                                 = var.env
  vpc_id                              = var.vpc_id
  vpc_cidr                            = var.vpc_cidr
  aws_region                          = var.region
  vpc_pvt_subnet_ids                  = var.private_subnets
  vpc_pub_subnet_ids                  = var.public_subnets
  project_name                        = var.project_name
  cluster_arn                         = module.ecs_cluster.aws_ecs_cluster_cluster_arn
  lb_enabled                          = "true"
  component                           = "service"
  port                                = 80
  health_check_code                   = 200
  health_check_path                   = "/health-check"
  command                             = null
  component_ecr_url                   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name}-nginx-${var.env}"
  component_image_tag                 = var.service_image_tag
  container_cpu                       = 2048
  container_memory                    = 4096
  certificate_arn                     = var.certificate_arn
  http_redirect                       = true
  internal_lb_enabled                 = false
  log_retention                       = var.log_retention
  service_connect                     = true
  service_discovery_namespace_arn     = aws_service_discovery_http_namespace.service_discovery.arn
  grafana_fluent_bit_plugin_loki      = false
  desired_count                       = 1
  autoscaling_max_capacity            = var.env == "prod" ? 10 : var.env == "staging" ? 1 : 1
  autoscaling_min_capacity            = var.env == "prod" ? 2 : var.env == "staging" ? 1 : 1
  schedule_scaling                    = true
  schedule_max_capacity               = "cron(0 15 * * ? *)"
  schedule_min_capacity               = "cron(0 6 * * ? *)"
  external_lb                         = true
  external_lb_arn_suffix              = var.external_lb_arn_suffix
  external_lb_target_group            = var.external_lb_target_group
  external_lb_target_group_arn_suffix = var.external_lb_target_group_arn_suffix
  external_lb_security_group          = var.external_lb_security_group
  environment_variables = [
    {
      name  = "ENVIRONMENT"
      value = var.deploy_env
    }
  ]
}

