locals {
  subnet_cidr_blocks        = [for cidr_block in cidrsubnets(var.vpc_cidr_block, 4) : cidrsubnets(cidr_block, 2, 2, 2)]
  public_subnet_cidr_blocks = local.subnet_cidr_blocks[0]
}

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zone.main)

  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zone.main[count.index].name
  cidr_block        = local.public_subnet_cidr_blocks[count.index]

  tags = merge(var.tags, {
    Name  = "${var.prefix}-public-subnet-${data.aws_availability_zone.main[count.index].name_suffix}"
    usage = "public"
  })
}
