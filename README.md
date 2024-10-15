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
  version                              = "1.0.8"
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
  environment_variables           = [
    {
      name  = "ENVIRONMENT"
      value = var.deploy_env
    }
  ]
}
```