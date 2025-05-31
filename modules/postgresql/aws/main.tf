data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-vpc"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "dmz" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-dmz-*"]
  }
}

data "aws_subnet" "dmz" {
  for_each = toset(data.aws_subnets.dmz.ids)
  id       = each.value
}

data "aws_nat_gateway" "nat" {
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-nat"]
  }
}

data "aws_subnets" "database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  
  filter {
    name   = "tag:Type"
    values = ["database"]
  }
}

resource "aws_subnet" "database" {
  count             = 2
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, 
    local.name_prefix == "${var.name_prefix}-pg" ? local.primary_subnet_offset + count.index :
    local.name_prefix == "${var.name_prefix}-pg-source" ? local.source_subnet_offset + count.index :
    local.dest_subnet_offset + count.index
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${local.name_prefix}-db-${data.aws_availability_zones.available.names[count.index]}"
    Type = "database"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${local.instance_name}-${random_id.db_name_suffix.hex}"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "${local.instance_name}-subnet-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "database" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${local.name_prefix}-db-rt"
  }
}

resource "aws_route_table_association" "database" {
  count          = 2
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "random_password" "admin" {
  length  = 20
  special = false
}

data "aws_security_groups" "platform" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-platform-*"]
  }
}

resource "aws_security_group" "postgres" {
  name        = "${local.instance_name}-${random_id.db_name_suffix.hex}"
  description = "Security group for PostgreSQL instance"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = local.database_port
    to_port     = local.database_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    description = "Allow access from VPC CIDR"
  }

  dynamic "ingress" {
    for_each = data.aws_subnets.dmz.ids
    content {
      from_port       = local.database_port
      to_port         = local.database_port
      protocol        = "tcp"
      cidr_blocks     = [data.aws_subnet.dmz[ingress.value].cidr_block]
      description     = "Allow access from DMZ subnet ${data.aws_subnet.dmz[ingress.value].tags["Name"]}"
    }
  }

  dynamic "ingress" {
    for_each = data.aws_security_groups.platform.ids
    content {
      from_port       = local.database_port
      to_port         = local.database_port
      protocol        = "tcp"
      security_groups = [ingress.value]
      description     = "Allow access from platform security group"
    }
  }

  # Allow access from bastion host
  ingress {
    from_port       = local.database_port
    to_port         = local.database_port
    protocol        = "tcp"
    security_groups = [data.aws_security_group.bastion.id]
    description     = "Allow access from bastion host"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.instance_name}-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${local.instance_name}-${random_id.db_name_suffix.hex}"
  family = "postgres${split(".", local.database_version)[0]}"

  dynamic "parameter" {
    for_each = local.max_connections > 0 ? [local.max_connections] : []
    content {
      name         = "max_connections"
      value        = tostring(parameter.value)
      apply_method = "pending-reboot"
    }
  }

  dynamic "parameter" {
    for_each = var.enable_detailed_logging ? [{
      name  = "log_statement"
      value = "all"
      }, {
      name  = "log_lock_waits"
      value = "1"
    }] : []
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = "immediate"
    }
  }

  dynamic "parameter" {
    for_each = local.replication || local.prep_upgrade_as_source_db ? [{
      name  = "rds.logical_replication"
      value = "1"
    }] : []
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = "pending-reboot"
    }
  }

  # Performance optimization parameters
  parameter {
    name         = "shared_buffers"
    value        = "{DBInstanceClassMemory/4}"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "effective_cache_size"
    value        = "{DBInstanceClassMemory*3/4}"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = "16384"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "maintenance_work_mem"
    value        = "2097152"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "random_page_cost"
    value        = "1.1"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "${local.instance_name}-pg-params"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "instance" {
  identifier = "${local.instance_name}-${random_id.db_name_suffix.hex}"

  engine         = "postgres"
  engine_version = local.database_version
  instance_class = local.instance_class

  allocated_storage     = var.allocated_storage
  storage_type         = var.allocated_storage >= 400 ? "io1" : "gp3"
  storage_encrypted    = true
  iops                 = var.allocated_storage >= 400 ? 12000 : null
  max_allocated_storage = var.allocated_storage * 2

  db_name  = "postgres"
  username = "postgres"
  password = random_password.admin.result

  vpc_security_group_ids = [aws_security_group.postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  parameter_group_name   = aws_db_parameter_group.postgres.name

  multi_az               = local.highly_available
  publicly_accessible    = var.publicly_accessible
  deletion_protection    = local.prep_upgrade_as_source_db ? false : !local.destroyable

  backup_retention_period = local.pre_promotion ? 0 : var.backup_retention_period
  backup_window          = local.pre_promotion ? null : var.backup_window
  maintenance_window     = local.pre_promotion ? null : var.maintenance_window
  auto_minor_version_upgrade = true

  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "${local.instance_name}-final-snapshot"

  performance_insights_enabled = true
  performance_insights_retention_period = 7
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.monitoring.arn

  enabled_cloudwatch_logs_exports = var.enable_detailed_logging ? ["postgresql", "upgrade"] : []

  iam_database_authentication_enabled = true

  tags = merge(
    {
      Name = "${local.instance_name}"
    },
    var.tags
  )

  depends_on = [
    aws_db_subnet_group.postgres,
    aws_security_group.postgres,
    aws_db_parameter_group.postgres,
    aws_iam_role.monitoring,
    aws_iam_role_policy_attachment.monitoring
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "replica" {
  count = local.provision_read_replica ? 1 : 0

  identifier = "${local.instance_name}-${random_id.db_name_suffix.hex}-replica"

  instance_class = local.instance_class
  replicate_source_db = aws_db_instance.instance.identifier

  multi_az = local.highly_available

  parameter_group_name = aws_db_parameter_group.postgres.name

  vpc_security_group_ids = [aws_security_group.postgres.id]

  backup_retention_period = 0
  skip_final_snapshot    = true
  deletion_protection    = false
  
  # Always set these for replicas to ensure clean deletion
  apply_immediately     = true
  auto_minor_version_upgrade = false

  tags = {
    Name = "${local.instance_name}-replica"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_db_instance.instance,
    aws_security_group.postgres,
    aws_db_parameter_group.postgres
  ]
}

# Create an IAM role for RDS IAM authentication
resource "aws_iam_role" "rds_iam" {
  name = "${local.instance_name}-${random_id.db_name_suffix.hex}-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

# Store credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "postgres_creds" {
  name = "${local.instance_name}-${random_id.db_name_suffix.hex}-creds"
}

resource "aws_secretsmanager_secret_version" "postgres_creds" {
  secret_id = aws_secretsmanager_secret.postgres_creds.id
  secret_string = jsonencode({
    username = aws_db_instance.instance.username
    password = random_password.admin.result
  })
}

# Create a null resource to ensure the RDS instance is ready
resource "null_resource" "wait_for_db" {
  depends_on = [aws_db_instance.instance]

  provisioner "local-exec" {
    command = "sleep 30"  # Wait for RDS to be fully ready
  }
}

provider "postgresql" {
  host            = "localhost"
  port            = 5433
  database        = "postgres"
  username        = aws_db_instance.instance.username
  password        = random_password.admin.result
  sslmode         = "require"
  connect_timeout = 30
  superuser       = false
}



module "database" {
  count    = var.create_databases ? length(local.databases) : 0
  source   = "./database"

  db_name            = local.databases[count.index]
  admin_user_name    = aws_db_instance.instance.username
  admin_password     = random_password.admin.result
  user_name          = "${local.databases[count.index]}-user"
  user_can_create_db = var.user_can_create_db
  instance_endpoint  = aws_db_instance.instance.endpoint
  replication        = local.replication

  depends_on = [null_resource.wait_for_db]
}

module "migration" {
  count                           = local.prep_upgrade_as_source_db ? 1 : 0
  source                          = "./migration"
  region                          = local.region
  database_port                   = local.database_port
  instance_name                   = local.instance_name
  destroyable                     = local.destroyable
  instance_class                  = local.instance_class
  highly_available                = local.highly_available
  enable_detailed_logging         = var.enable_detailed_logging
  replication                     = local.replication
  destination_database_version    = local.destination_database_version
  migration_databases             = local.migration_databases
  max_connections                 = local.max_connections
  vpc_id                          = data.aws_vpc.vpc.id
  subnet_ids                      = aws_subnet.database[*].id
  source_instance_endpoint        = aws_db_instance.instance.endpoint
  depends_on                      = [aws_db_instance.instance, module.database]
}

resource "aws_iam_role" "monitoring" {
  name = "${local.instance_name}-${random_id.db_name_suffix.hex}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${local.instance_name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors RDS CPU utilization"
  alarm_actions      = []  # Add SNS topic ARN if needed

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.instance.id
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_low" {
  alarm_name          = "${local.instance_name}-free-storage-space-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "FreeStorageSpace"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "5000000000"  # 5GB in bytes
  alarm_description  = "This metric monitors RDS free storage space"
  alarm_actions      = []  # Add SNS topic ARN if needed

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.instance.id
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_low" {
  alarm_name          = "${local.instance_name}-freeable-memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "FreeableMemory"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "100000000"  # 100MB in bytes
  alarm_description  = "This metric monitors RDS freeable memory"
  alarm_actions      = []  # Add SNS topic ARN if needed

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.instance.id
  }
}

resource "aws_cloudwatch_metric_alarm" "connection_count_high" {
  alarm_name          = "${local.instance_name}-connection-count-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "DatabaseConnections"
  namespace          = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = local.max_connections > 0 ? local.max_connections * 0.8 : 100
  alarm_description  = "This metric monitors RDS connection count"
  alarm_actions      = []  # Add SNS topic ARN if needed

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.instance.id
  }
}

# Add data source for bastion security group
data "aws_security_group" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-bastion-sg"]
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}
