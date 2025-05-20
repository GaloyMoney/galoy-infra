resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  tags = { Name = local.vpc_name }
}

locals {
  public_map  = zipmap(local.public_subnet_names, local.public_subnet_cidrs)
  private_map = zipmap(local.private_subnet_names, local.private_subnet_cidrs)
}

resource "aws_subnet" "public" {
  for_each                = local.public_map
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = local.azs[tonumber(regex(".*-(\\d+)$", each.key)[0])]
  map_public_ip_on_launch = true
  tags = { Name = each.key }
}

resource "aws_subnet" "private" {
  for_each                = local.private_map
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = local.azs[tonumber(regex(".*-(\\d+)$", each.key)[0])]
  map_public_ip_on_launch = false
  tags = { Name = each.key }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.prefix}-igw" }
}

resource "aws_eip" "nat" {
  count = length(local.azs)
  vpc   = true
  tags  = { Name = "${local.prefix}-nat-${count.index}" }
}

resource "aws_nat_gateway" "gw" {
  count         = length(local.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[local.public_subnet_names[count.index]].id
  tags          = { Name = "${local.prefix}-nat-${count.index}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${local.prefix}-rt-public" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.main.id
  tags     = { Name = "${each.key}-rt-private" }
}

resource "aws_route" "private_nat" {
  count                   = length(aws_nat_gateway.gw)
  route_table_id          = aws_route_table.private[local.private_subnet_names[count.index]].id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.gw[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}