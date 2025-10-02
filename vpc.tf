resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  tags = {
    Name = "ecs-gw"
  }
}

resource "aws_internet_gateway_attachment" "this" {
  internet_gateway_id = aws_internet_gateway.this.id
  vpc_id              = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "ecs-rt"
  }
}

resource "aws_route" "this" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_subnet" "public" {
  for_each          = { for i in range(var.num_subnets) : "public-${i}" => i }
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[each.value % length(local.azs)]
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, each.value)
  tags = {
    Name = "ecs-subnet-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each          = { for i in range(var.num_subnets) : "private-${i}" => i }
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[each.value % length(local.azs)]
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, each.value + length(local.azs))
  tags = {
    Name = "ecs-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "this" {
  for_each       = aws_subnet.public
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.this.id
}