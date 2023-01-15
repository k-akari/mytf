resource "aws_iam_role" "ecs_task_execution" {
  # required arguments
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  # optional arguments
  name = "${var.prefix}-ecs-task-execution-role"
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  # required arguments
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
