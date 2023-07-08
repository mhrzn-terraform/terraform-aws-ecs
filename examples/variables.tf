variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the ECS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "A VPC CIDR"
  type        = string
}

variable "region" {
  description = "AWS Region to deploy ECS cluster"
  type = string
}

variable "private_subnets" {
  description = "A list of Private Subnets"
  type = list(string)
}

variable "public_subnets" {
  description = "A list of Public Subnets"
  type = list(string)
}

variable "project_name" {
  description = "Project Name to be used in resource name as suffix and prefix"
  type = string
}

variable "service_name" {
  description = "ECS service name"
  type = string
}

variable "env" {
  description = "Environment stage to deploy resource"
  type = string
}

variable "deploy_env" {
  type = string
}

variable "hostname" {
  description = "Root DNS name for ALB"
  type = string
}

variable "zone" {
  description = "Route53 DNS zone to create records"
  type = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for ALB"
  type = string
}

variable "containerInsights" {
  description = "Enables container insights if true"
  type = bool
}

variable "service_image_tag" {
  description = "Image tag of app service"
  type = string
}

variable "log_retention" {
  description = "Log retentation days for service logs in cloudwatch"
  type = number
}