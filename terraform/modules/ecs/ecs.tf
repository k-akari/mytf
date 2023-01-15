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
  tags          = var.tags
  task_role_arn = aws_iam_role.ecs_task.arn
}

resource "aws_ecs_service" "main" {
  count = length(var.task_definitions)

  # required arguments
  name = "${var.prefix}-ecs-service-${var.task_definitions[count.index].family}"

  # optional arguments
  cluster                 = aws_ecs_cluster.main.arn
  desired_count           = 0
  enable_ecs_managed_tags = true
  enable_execute_command  = true
  launch_type             = "FARGATE"
  network_configuration {
    # required arguments
    subnets = var.subnet_ids

    # optional arguments
    assign_public_ip = true
  }
  platform_version = "LATEST"
  propagate_tags   = "TASK_DEFINITION"
  task_definition  = aws_ecs_task_definition.main[count.index].arn
  tags             = var.tags
}
