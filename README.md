# AWS ECS Terraform module

Terraform module which creates ECS (Elastic Container Service) resources on AWS.

## Available Features

- ECS cluster w/ Fargate
- ECS Service w/ task definition, task set, and container definition support
- Service Discovery with Cloudmap

## Usage

```
module "service" {
  source                               = "mhrzn-terraform/ecs/aws"
  version                              = "1.0.11"
  env                                  = "dev"
  vpc_id                               = "vpc-08fa46523c7cd7e21"
  vpc_cidr                             = "172.31.0.0/16"
  aws_region                           = "ap-south-1"
  vpc_pvt_subnet_ids                   = ["subnet-051a4e5879d10a66e","subnet-070c4103d0cb5180a"]
  vpc_pub_subnet_ids                   = ["subnet-09702b1b6db693bba","subnet-051a4e5879d10a66e"]
  project_name                         = "ECS-TEST"
  cluster_arn                          = <ecs_cluster_arn>
  lb_enabled                           = "true"
  component                            = "service"
  port                                 = 80
  health_check_code                    = 200
  health_check_path                    = "/health-check"
  command                              = null
  component_ecr_url                    = <image_url/name>
  component_image_tag                  = <image_tag>
  container_cpu                        = 2048
  container_memory                     = 4096
  certificate_arn                      = <acm_certificate_arn>
  http_redirect                        = true
  internal_lb_enabled                  = false
  log_retention                        = 1
  service_connect                      = true
  service_discovery_namespace_arn      = <service_discovery_arn>
  grafana_fluent_bit_plugin_loki       = true
  grafana_fluent_bit_plugin_loki_image = "grafana/fluent-bit-plugin-loki:2.9.1"
  grafana_loki_url                     = "https://<grafana_loki_url>"
  desired_count                        = 1
  autoscaling_max_capacity             = var.env == "prod" ? 10 : var.env == "staging" ? 1 : 1
  autoscaling_min_capacity             = var.env == "prod" ? 2 : var.env == "staging" ? 1 : 1
  schedule_scaling                     = true
  schedule_max_capacity                = "cron(0 15 * * ? *)"
  schedule_min_capacity                = "cron(0 6 * * ? *)"
  external_lb                          = true
  external_lb_arn_suffix               = "<load balancer arn suffix>"
  external_lb_target_group             = "<load balancer target group>"
  external_lb_target_group_arn_suffix  = "<load balancer target group arn suffix>"
  external_lb_security_group           = "<security group id of external load balancer>"
  enable_public_ip                     = true
  environment_variables                = [
    {
      name  = "ENVIRONMENT"
      value = var.deploy_env
    }
  ]
}
```