data "aws_availability_zone" "main" {
  count = length(var.availability_zone_names)
  name  = var.availability_zone_names[count.index]
}
