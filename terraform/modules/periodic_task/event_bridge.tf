resource "aws_cloudwatch_event_rule" "main" {
  count = length(var.event_rules)

  # optional arguments
  name                = "${var.prefix}-${var.event_rules[count.index].name}"
  schedule_expression = var.event_rules[count.index].cron
  role_arn            = aws_iam_role.main.arn
  is_enabled          = true
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "main" {
  count = length(var.event_rules)

  # required arguments
  arn  = var.ecs_cluster_arn
  rule = aws_cloudwatch_event_rule.main[count.index].name

  # optional arguments
  ecs_target {
    # required arguments
    task_definition_arn = var.task_definition_arn

    # optional arguments
    enable_ecs_managed_tags = true
    enable_execute_command  = true
    launch_type             = "FARGATE"
    network_configuration {
      # required arguments
      subnets = var.subnet_ids

      # optional arguments
      assign_public_ip = false
      security_groups  = [aws_security_group.main.id]
    }
    platform_version = "LATEST"
    task_count       = 1
  }
}
