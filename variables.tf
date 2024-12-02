variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the ECS cluster"
  type        = string
}
variable "vpc_cidr" {
  description = "A VPC CIDR"
  type        = string
}
variable "aws_region" {
  description = "AWS Region to deploy ECS cluster"
  type        = string
}
variable "vpc_pvt_subnet_ids" {
  description = "A list of Private Subnets"
  type        = list(string)
  default     = null
}
variable "vpc_pub_subnet_ids" {
  description = "A list of Public Subnets"
  type        = list(string)
  default     = null
}

variable "project_name" {
  description = "Project Name to be used in resource name as suffix and prefix"
  type        = string
}

variable "env" {
  description = "Environment stage to deploy resource"
  type        = string
}

variable "cluster_arn" {
  description = "ECS cluster arn"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "lb_enabled" {
  description = "Enables ALB for component"
  type        = bool
  default     = false
}

variable "component" {
  description = "Component name (Microservice Name)"
  type        = string
  default     = "serviceA"
}

variable "port" {
  description = "Service port"
  type        = number
  default     = 80
}

variable "health_check_code" {
  description = "Service health check response code"
  type        = number
  default     = null
}

variable "health_check_path" {
  description = "Service health check path"
  type        = string
  default     = null
}

variable "command" {
  description = "Command to run in Container"
  type        = string
  default     = null
}

variable "component_ecr_url" {
  description = "ECR url for component"
  type        = string
}

variable "component_image_tag" {
  description = "Image tag of component"
  type        = string
}

variable "container_cpu" {
  description = "CPU allocation for component container"
  type        = number
  default     = 512
}

variable "container_memory" {
  description = "Memory allocation for component container"
  type        = number
  default     = 1024
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
}

variable "secrets_manager_secret_arn" {
  description = "Secrets Manager Secret ARN"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "SSL Certificate for ALB"
  type        = string
  default     = null
}

variable "http_redirect" {
  description = "ALB HTTP to HTTP redirection"
  type        = bool
  default     = null
}

variable "internal_lb_enabled" {
  description = "Internal facing loadbalancer"
  type        = bool
  default     = null
}

variable "log_retention" {
  description = "Log retentation days for service logs in cloudwatch"
  type        = number
  default     = 7
}

variable "service_connect" {
  description = "Variable to enable service discovery"
  type        = bool
  default     = false
}

variable "service_discovery_namespace_arn" {
  description = "Service Discovery ARN"
  type        = string
  default     = null
}

variable "grafana_fluent_bit_plugin_loki" {
  description = "Enable if Grafana Loki log router using fluentbit firelens is required"
  type        = string
  default     = false
}

variable "grafana_fluent_bit_plugin_loki_image" {
  description = "Image and tag of Grafana Fluentbit plugin Loki"
  type        = string
  default     = "grafana/fluent-bit-plugin-loki:2.9.1"
}

variable "grafana_loki_url" {
  description = "Full URL of Grafana Loki"
  type        = string
  default     = null
}

variable "desired_count" {
  description = "ECS service task count"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "App Autoscaling maximum capacity"
  type        = number
  default     = 2
}

variable "autoscaling_min_capacity" {
  description = "App Autoscaling minimum capacity"
  type        = number
  default     = 1
}

variable "schedule_scaling" {
  description = "Enable if schedule scaling is requried"
  type        = string
  default     = false
}

variable "scale_in_schedule" {
  description = "Crontab Schedule to scale in"
  type        = string
  default     = "cron(0 15 * * ? *)"
}

variable "scale_out_schedule" {
  description = "Crontab Schedule to scale out"
  type        = string
  default     = "cron(0 6 * * ? *)"
}

variable "schedule_min_capacity" {
  description = "Autoscaling Schedule Minimum Capacity"
  type        = number
  default     = 1
}

variable "schedule_max_capacity" {
  description = "Autoscaling Maximum Capacity"
  type        = number
  default     = 1
}

variable "external_lb" {
  description = "Enable for external ALB"
  type        = string
  default     = false
}

variable "external_lb_arn_suffix" {
  description = "External Load Balancer ARN suffix"
  type        = string
}

variable "external_lb_target_group" {
  description = "External Load Balancer Target Group"
  type        = string
}

variable "external_lb_target_group_arn_suffix" {
  description = "External Load Balancer Target Group ARN suffix"
  type        = string
}

variable "external_lb_security_group" {
  description = "Security Group ID of External Load Balancer"
  type        = string
}

variable "enable_public_ip" {
  description = "Flag to assign public IP ECS task"
  type        = bool
  default     = false
}