resource "aws_iam_role" "main" {
  name = "${var.prefix}-event-bridge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect = "Allow"
      Principals = {
        Identifiers = [
          "events.amazonaws.com"
        ]
        Type = "Service"
      }
      Actions = [
        "sts:AssumeRole"
      ]
    }
  })
}

resource "aws_iam_policy" "main" {
  name = "${var.prefix}-event-bridge-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Actions = [
          "ecs:RunTask"
        ]
        Effect    = "Allow"
        Resources = var.ecs_cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
