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