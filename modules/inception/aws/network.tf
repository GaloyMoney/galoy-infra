resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.default_tags, {
    Name = "${local.prefix}-vpc"
  })
}


resource "aws_subnet" "public" {
  for_each                = var.azs            
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(local.default_tags, {
    Name                     = "${local.prefix}-public-${each.key}"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, { Name = "${local.prefix}-igw" })
}

resource "aws_eip" "nat" {
  count = length(var.azs)
  vpc   = true
  tags  = merge(local.default_tags, { Name = "${local.prefix}-nat-${count.index}" })
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(values(aws_subnet.public)[*].id, count.index)

  tags = merge(local.default_tags, { Name = "${local.prefix}-nat-${count.index}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, { Name = "${local.prefix}-rt-public" })
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




resource "aws_subnet" "dmz_private" {
  for_each                = local.azs_dmz
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(local.default_tags, {
    Name = "${local.prefix}-dmz-${each.key}"
  })
}

locals {
  nat_ids_by_az = { for idx, az in keys(var.azs) :
    az => aws_nat_gateway.nat[idx].id
  }
}

resource "aws_route_table" "dmz" {
  for_each = aws_subnet.dmz_private
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = local.nat_ids_by_az[each.key]
  }

  tags = local.default_tags
}

resource "aws_route_table_association" "dmz_assoc" {
  for_each       = aws_subnet.dmz_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.dmz[each.key].id
}


resource "aws_security_group" "endpoints" {
  name   = "${local.prefix}-endpoints"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTPS from bastion subnet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.dmz_private : subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.default_tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.dmz_private)[*].id
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags                = local.default_tags
}
