resource "aws_iam_role" "main" {
  # required arguments
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  # optional arguments
  name = "${var.prefix}-event-bridge-role"
  tags = var.tags
}

resource "aws_iam_policy" "main" {
  # required arguments
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RunTask",
        ]
        Effect   = "Allow"
        Resource = replace(var.task_definition_arn, "/:\\d+$/", ":*")
      },
      {
        Action = [
          "iam:PassRole",
        ]
        Effect = "Allow"
        Resource = [
          var.ecs_task_execution_role_arn,
          var.ecs_task_role_arn,
        ]
      }
    ]
  })

  # optional arguments
  name = "${var.prefix}-event-bridge-policy"
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "main" {
  # required arguments
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
