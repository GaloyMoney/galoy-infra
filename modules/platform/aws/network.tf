resource "aws_subnet" "cluster_private" {
  for_each                = var.azs_cluster
  vpc_id                  = data.aws_vpc.inception.id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  availability_zone       = each.key
  tags = {
    Name = "${var.name_prefix}-cluster-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "cluster" {
  for_each = var.azs_cluster

  vpc_id = data.aws_vpc.inception.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = local.nat_gateway_ids[index(keys(var.azs_cluster), each.key)]
  }

  tags = {
    Name = "${var.name_prefix}-cluster-${each.key}"
  }
}

resource "aws_route_table_association" "cluster_assoc" {
  for_each = aws_subnet.cluster_private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.cluster[each.value.availability_zone].id
}

