output "ecs_cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "task_definition_arns" {
  value = aws_ecs_task_definition.main[*].arn
}