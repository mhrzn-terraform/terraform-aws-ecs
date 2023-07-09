resource "aws_service_discovery_http_namespace" "service_discovery" {
  name        = "${var.project_name}.${var.env}.local"
  description = "Service Discovery Namespace for ${var.env} environment"
}