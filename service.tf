#------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
#------------------------------------------------------------------------------
resource "aws_lb" "lb" {
  count                            = !var.lb_enabled || var.external_lb ? 0 : 1
  name                             = var.internal_lb_enabled ? "${var.project_name}-${var.component}-lb-${var.env}-in" : "${var.project_name}-${var.component}-lb-${var.env}"
  internal                         = var.internal_lb_enabled
  load_balancer_type               = "application"
  drop_invalid_header_fields       = false
  subnets                          = var.internal_lb_enabled ? var.vpc_pvt_subnet_ids : var.vpc_pub_subnet_ids
  idle_timeout                     = 60
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false
  enable_http2                     = true
  ip_address_type                  = "ipv4"
  security_groups                  = [aws_security_group.lb_access_sg[count.index].id]

  tags = {
    Name = "${var.env}-${var.component}-lb-${var.env}"
  }
}

#------------------------------------------------------------------------------
# ACCESS CONTROL TO APPLICATION LOAD BALANCER
#------------------------------------------------------------------------------
resource "aws_security_group" "lb_access_sg" {
  count       = !var.lb_enabled || var.external_lb ? 0 : 1
  name        = "${var.project_name}-${var.component}-lb-sg-${var.env}"
  description = "Controls access to the Load Balancer"
  vpc_id      = var.vpc_id
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-${var.component}-lb-sg-${var.env}"
  }
}

resource "aws_security_group_rule" "ingress_through_http" {
  count             = !var.lb_enabled || var.external_lb ? 0 : 1
  security_group_id = aws_security_group.lb_access_sg[count.index].id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  prefix_list_ids   = []
}

resource "aws_security_group_rule" "ingress_through_https" {
  count             = !var.lb_enabled || var.external_lb ? 0 : 1
  security_group_id = aws_security_group.lb_access_sg[count.index].id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  prefix_list_ids   = []
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER - Target Groups
#------------------------------------------------------------------------------
resource "aws_lb_target_group" "lb_http_tgs" {
  count                         = !var.lb_enabled || var.external_lb ? 0 : 1
  name                          = "${var.project_name}-${var.component}-tg-${var.env}"
  port                          = var.port
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  deregistration_delay          = 300
  slow_start                    = 0
  load_balancing_algorithm_type = "round_robin"
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = var.port
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = var.health_check_code
  }
  target_type = "ip"
  tags = {
    Name = "${var.project_name}-${var.component}-tg-${var.env}"
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_lb.lb]
}

#------------------------------------------------------------------------------
# AWS LOAD BALANCER - Listeners
#------------------------------------------------------------------------------
resource "aws_lb_listener" "lb_http_listeners" {
  count             = !var.lb_enabled || var.external_lb ? 0 : 1
  load_balancer_arn = aws_lb.lb[count.index].arn
  port              = 80
  protocol          = "HTTP"
  dynamic "default_action" {
    for_each = var.http_redirect ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.http_redirect ? [] : range(length(aws_lb_target_group.lb_http_tgs.*.arn))
    content {
      target_group_arn = aws_lb_target_group.lb_http_tgs[count.index].arn
      type             = "forward"
    }
  }
}

resource "aws_lb_listener" "lb_https_listeners" {
  count             = !var.lb_enabled || var.external_lb ? 0 : 1
  load_balancer_arn = aws_lb.lb[count.index].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    target_group_arn = aws_lb_target_group.lb_http_tgs[count.index].arn
    type             = "forward"
  }
}
//
//resource "aws_lb_listener_certificate" "lb_http_listener_certificate" {
//  listener_arn    = aws_lb_listener.lb_https_listeners.arn
//  certificate_arn = var.beta_certificate_arn
//}

//resource "aws_lb_listener_certificate" "lb_http_listener_certificate_2" {
//  listener_arn    = aws_lb_listener.lb_https_listeners.arn
//  certificate_arn = var.certificate_arn
//}

resource "aws_cloudwatch_log_group" "cloudwatch_lg" {
  name              = "${var.project_name}-${var.component}-${var.env}"
  retention_in_days = var.log_retention
}

module "fluentbit_definition" {
  count           = var.grafana_fluent_bit_plugin_loki ? 1 : 0
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "0.58.1"
  container_image = var.grafana_fluent_bit_plugin_loki_image
  container_name  = "${var.project_name}-${var.component}-log-router-ct"
  firelens_configuration = {
    type = "fluentbit",
    options = {
      enable-ecs-log-metadata = "true"
    }
  }
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "${var.project_name}-${var.component}-${var.env}"
      awslogs-region        = var.aws_region
      awslogs-stream-prefix = "firelens"
    }
    secretOptions = []
  }
}

module "definition" {
  source           = "./modules/terraform-aws-ecs-container-definition/"
  container_image  = "${var.component_ecr_url}:${var.component_image_tag}"
  container_name   = "${var.project_name}-${var.component}-ct"
  container_cpu    = var.container_cpu
  container_memory = var.container_memory
  command          = [var.command]
  port_mappings = [{
    name          = "${var.component}-${var.port}-http"
    containerPort = var.port
    hostPort      = var.port
    protocol      = "tcp"
    appProtocol   = "http"
  }]

  log_configuration = var.grafana_fluent_bit_plugin_loki ? {
    logDriver = "awsfirelens"
    options = {
      Name       = "grafana-loki"
      Url        = var.grafana_loki_url
      Labels     = "{job=\"firelens-${var.project_name}-${var.component}\",environment=\"${var.env}\"}"
      RemoveKeys = "container_id,ecs_task_arn"
      LabelKeys  = "container_name,ecs_task_definition,source,ecs_cluster"
      LineFormat = "key_value"
    }
    secretOptions = []
    } : {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "${var.project_name}-${var.component}-${var.env}"
      awslogs-region        = var.aws_region
      awslogs-stream-prefix = "${var.component}"
    }
    secretOptions = []
  }

  environment = [
    for env in var.environment_variables : {
      name  = env.name
      value = env.value
    }
  ]

  secrets = [
    for secret in var.secrets : {
      name      = secret.name
      valueFrom = secret.valueFrom
    }
  ]
}

module "td_fluent_bit" {
  count            = var.grafana_fluent_bit_plugin_loki ? 1 : 0
  source           = "./modules/ecs_td"
  name_prefix      = "${var.project_name}-${var.component}-td-${var.env}"
  container_cpu    = var.container_cpu
  container_memory = var.container_memory

  containers = [
    module.fluentbit_definition[0].json_map_object,
    module.definition.json_map_object
  ]

  ecs_task_execution_role_custom_policies = var.secrets != null && length(var.secrets) > 0 ? [
    jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "secretsmanager:GetSecretValue"
            ],
            "Resource" : [
              "${var.secrets_manager_secret_arn}"
            ]
          }
        ]
      }
    )
  ] : []
}

module "td_default" {
  count            = var.grafana_fluent_bit_plugin_loki ? 0 : 1
  source           = "./modules/ecs_td"
  name_prefix      = "${var.project_name}-${var.component}-td-${var.env}"
  container_cpu    = var.container_cpu
  container_memory = var.container_memory

  containers = [
    module.definition.json_map_object
  ]

  ecs_task_execution_role_custom_policies = var.secrets != null && length(var.secrets) > 0 ? [
    jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "secretsmanager:GetSecretValue"
            ],
            "Resource" : [
              "${var.secrets_manager_secret_arn}"
            ]
          }
        ]
      }
    )
  ] : []
}

#------------------------------------------------------------------------------
# AWS ECS SERVICE
#------------------------------------------------------------------------------
resource "aws_ecs_service" "service" {
  name = "${var.project_name}-${var.component}-${var.env}"
  # capacity_provider_strategy - (Optional) The capacity provider strategy to use for the service. Can be one or more. Defined below.
  cluster                            = var.cluster_arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = false
  health_check_grace_period_seconds  = 0
  launch_type                        = "FARGATE"
  force_new_deployment               = true
  enable_execute_command             = true

  dynamic "load_balancer" {
    for_each = var.external_lb ? [1] : []
    content {
      target_group_arn = var.external_lb_target_group
      container_name   = "${var.project_name}-${var.component}-ct"
      container_port   = var.port
    }
  }

  dynamic "load_balancer" {
    for_each = !var.external_lb && var.lb_enabled ? { for i in range(1) : i => aws_lb_target_group.lb_http_tgs[i] } : {}
    content {
      target_group_arn = load_balancer.value.arn
      container_name   = "${var.project_name}-${var.component}-ct"
      container_port   = load_balancer.value.port
    }
  }

  network_configuration {
    security_groups  = [aws_security_group.sg.id]
    subnets          = var.enable_public_ip ? var.vpc_pub_subnet_ids : var.vpc_pvt_subnet_ids
    assign_public_ip = var.enable_public_ip ? true : false
  }

  platform_version = "1.4.0"
  propagate_tags   = "SERVICE"
  #task_definition  = module.td.aws_ecs_task_definition_td_arn
  task_definition = var.grafana_fluent_bit_plugin_loki ? module.td_fluent_bit[0].aws_ecs_task_definition_td_arn : module.td_default[0].aws_ecs_task_definition_td_arn

  dynamic "service_connect_configuration" {
    for_each = var.service_connect ? [1] : []
    content {
      enabled   = var.service_connect
      namespace = var.service_discovery_namespace_arn
      service {
        discovery_name = var.component
        port_name      = "${var.component}-${var.port}-http"
        client_alias {
          dns_name = var.component
          port     = var.port
        }
      }
    }
  }
  tags = {
    Name = "${var.project_name}-${var.component}-${var.env}"
  }
  depends_on = [aws_lb_listener.lb_http_listeners]
  #depends_on = [aws_lb_listener.lb_http_listeners, aws_lb_listener.lb_https_listeners]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70
    scale_in_cooldown  = 300
    scale_out_cooldown = 10
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "memory-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 90
    scale_in_cooldown  = 300
    scale_out_cooldown = 10
  }
}

resource "aws_appautoscaling_policy" "ecs_alb_policy" {
  count              = var.lb_enabled || var.external_lb ? 1 : 0
  name               = "alb-request-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.external_lb ? "${var.external_lb_arn_suffix}/${var.external_lb_target_group_arn_suffix}" : "${aws_lb.lb[count.index].arn_suffix}/${aws_lb_target_group.lb_http_tgs[count.index].arn_suffix}"
    }

    target_value       = 10000
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_scheduled_action" "ecs_schedule_scale_in" {
  count              = var.schedule_scaling ? 1 : 0
  name               = "schedule-auto-scaling-in"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = var.scale_in_schedule
  timezone           = "GMT"

  scalable_target_action {
    min_capacity = var.schedule_min_capacity
    max_capacity = var.schedule_min_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "ecs_schedule_scale_out" {
  count              = var.schedule_scaling ? 1 : 0
  name               = "schedule-auto-scaling-out"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = var.scale_out_schedule
  timezone           = "GMT"

  scalable_target_action {
    min_capacity = var.schedule_max_capacity
    max_capacity = var.schedule_max_capacity
  }
}

#------------------------------------------------------------------------------
# AWS SECURITY GROUP - ECS Tasks, allow traffic only from Load Balancer
#------------------------------------------------------------------------------
resource "aws_security_group" "sg" {
  name        = "${var.project_name}-${var.component}-ecs-task-sg-${var.env}"
  description = "Allow inbound access from the LB only"
  vpc_id      = var.vpc_id
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "Allows from ecs services"
  }
  dynamic "ingress" {
    for_each = !var.external_lb && var.lb_enabled ? { for i in range(1) : i => aws_security_group.lb_access_sg[i] } : {}
    content {
      from_port       = var.port
      to_port         = var.port
      protocol        = "TCP"
      security_groups = [ingress.value.id]
      description     = "Allows from ecs services"
    }
  }
  tags = {
    Name = "${var.project_name}-${var.component}-ecs-task-sg-${var.env}"
  }
}

//resource "aws_security_group_rule" "ingress_through_external_lb" {
//  count                    = var.external_lb && !var.lb_enabled ? 1 : 0
//  security_group_id        = aws_security_group.sg.id
//  type                     = "ingress"
//  from_port                = var.port
//  to_port                  = var.port
//  protocol                 = "TCP"
//  source_security_group_id = var.external_lb_security_group
//  description              = "Allows to ecs services from external lb"
//}

