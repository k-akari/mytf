output "ecs_cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "task_definition_arns" {
  value = aws_ecs_task_definition.main[*].arn
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}
