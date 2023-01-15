resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-ecs-cluster"
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  cluster_name       = aws_ecs_cluster.main.name
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"

    base   = 1
    weight = 100
  }
}

resource "aws_ecs_task_definition" "main" {
  count = length(var.task_definitions)

  # required arguments
  family = var.task_definitions[count.index].family
  container_definitions = jsonencode([
    {
      name      = "ruby"
      essential = true
      command   = var.task_definitions[count.index].command
      image     = "public.ecr.aws/docker/library/ruby:slim-buster"
      linuxParameters = {
        initProcessEnabled = true
      }
      healthCheck = {
        retries = 3
        command = [
          "CMD-SHELL",
          "ps aux | grep runner"
        ]
        timeout     = 5
        interval    = 30
        startPeriod = 15
      }
    },
  ])

  # optional arguments
  cpu                      = var.task_definitions[count.index].cpu
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  memory                   = var.task_definitions[count.index].memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  skip_destroy = true
  tags         = var.tags
}

resource "aws_ecs_service" "main" {
  count = length(var.task_definitions)

  # required arguments
  name = "${var.prefix}-ecs-service"

  # optional arguments
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 0
  }
  cluster                            = aws_ecs_cluster.main.arn
  deployment_maximum_percent         = 10
  deployment_minimum_healthy_percent = 0
  desired_count                      = 0
  enable_ecs_managed_tags            = true
  enable_execute_command             = true
  force_new_deployment               = true
  launch_type                        = "FARGATE"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_count]
  }
  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
  }
  platform_version = "LATEST"
  propagate_tags   = "TASK_DEFINITION"
  task_definition  = aws_ecs_task_definition.main[count.index].arn
}
