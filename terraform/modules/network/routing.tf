resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.prefix}-igw"
  })
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags                   = merge(var.tags, { Name = "${var.prefix}-rt-main" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.prefix}-rt-public"
  })
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(data.aws_availability_zone.main)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
