# AWS ECS Terraform module

Terraform module which creates ECS (Elastic Container Service) resources on AWS.

## Available Features

- ECS cluster w/ Fargate
- ECS Service w/ task definition, task set, and container definition support
- Service Discovery with Cloudmap

## Usage

```
module "service" {
  source                          = "github.com/mhrzn-terraform/terraform-aws-ecs/modules?ref=main"
  env                             = var.env
  vpc_id                          = var.vpc_id
  vpc_cidr                        = var.vpc_cidr
  aws_region                      = var.region
  vpc_pvt_subnet_ids              = var.private_subnets
  vpc_pub_subnet_ids              = var.public_subnets
  project_name                    = var.project_name
  cluster_arn                     = module.ecs_cluster.aws_ecs_cluster_cluster_arn
  lb_enabled                      = "true"
  component                       = "service"
  port                            = 80
  health_check_code               = 200
  health_check_path               = "/health-check"
  command                         = null
  component_ecr_url               = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name}-nginx-${var.env}"
  component_image_tag             = var.service_image_tag
  container_cpu                   = 2048
  certificate_arn                 = var.certificate_arn
  http_redirect                   = true
  internal_lb_enabled             = false
  log_retention                   = var.log_retention
  service_connect                 = true
  service_discovery_namespace_arn = aws_service_discovery_http_namespace.service_discovery.arn
  environment_variables           = [
    {
      name  = "ENVIRONMENT"
      value = var.deploy_env
    }
  ]
}
```