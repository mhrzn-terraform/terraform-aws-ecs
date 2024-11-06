output "lb_dns_name" {
  value = var.lb_enabled && !var.external_lb ? aws_lb.lb[0].dns_name : null
}

output "lb_zone_id" {
  value = var.lb_enabled && !var.external_lb ? aws_lb.lb[0].zone_id : null
}

output "lb_access_sg_id" {
  value = var.lb_enabled && !var.external_lb ? aws_security_group.lb_access_sg[0].id : null
}

output "lb_access_sg_arn" {
  value = var.lb_enabled && !var.external_lb ? aws_security_group.lb_access_sg[0].arn : null
}

output "ecs_service_id" {
  value = aws_ecs_service.service.id
}

output "ecs_service_security_group_id" {
  value = aws_security_group.sg.id
}

output "ecs_service_security_group_arn" {
  value = aws_security_group.sg.arn
}
