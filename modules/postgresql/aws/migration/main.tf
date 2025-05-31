variable "region" {}
variable "database_port" {}
variable "instance_name" {}
variable "destroyable" {}
variable "instance_class" {}
variable "highly_available" {}
variable "enable_detailed_logging" {}
variable "replication" {}
variable "destination_database_version" {}
variable "migration_databases" {}
variable "max_connections" {}
variable "vpc_id" {}
variable "subnet_ids" {}
variable "source_instance_endpoint" {}

output "source_connection_profile_id" {
  description = "The ID of the source connection profile"
  value       = aws_dms_endpoint.source.endpoint_id
}

output "postgres_user_password" {
  description = "Value of password for the postgres user"
  value       = random_password.postgres.result
}

output "destination_connection_profile_id" {
  description = "The ID of the destination connection profile"
  value       = aws_dms_endpoint.destination.endpoint_id
}

output "destination_instance_endpoint" {
  description = "The endpoint for destination instance"
  value       = aws_db_instance.destination_instance.endpoint
}

resource "random_id" "db_name_suffix_destination" {
  byte_length = 4
}

resource "random_password" "postgres" {
  length  = 20
  special = false
}

resource "aws_db_parameter_group" "destination" {
  family = "postgres${split(".", var.destination_database_version)[0]}"
  name   = "${var.instance_name}-${random_id.db_name_suffix_destination.hex}-dest"

  dynamic "parameter" {
    for_each = var.max_connections > 0 ? [var.max_connections] : []
    content {
      name  = "max_connections"
      value = var.max_connections
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
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  dynamic "parameter" {
    for_each = var.replication ? ["on"] : []
    content {
      name  = "rds.logical_replication"
      value = 1
    }
  }
}

resource "aws_db_subnet_group" "destination" {
  name       = "${var.instance_name}-${random_id.db_name_suffix_destination.hex}-dest"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.instance_name}-dest-subnet-group"
  }
}

resource "aws_security_group" "destination" {
  name        = "${var.instance_name}-${random_id.db_name_suffix_destination.hex}-dest"
  description = "Security group for destination PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "destination_instance" {
  identifier = "${var.instance_name}-${random_id.db_name_suffix_destination.hex}-dest"

  engine         = "postgres"
  engine_version = var.destination_database_version

  instance_class = var.instance_class
  multi_az       = var.highly_available

  db_name  = "postgres"
  username = "postgres"
  password = random_password.postgres.result

  allocated_storage     = 20
  storage_type         = "gp2"
  storage_encrypted    = true
  skip_final_snapshot  = true
  deletion_protection  = false

  db_subnet_group_name   = aws_db_subnet_group.destination.name
  vpc_security_group_ids = [aws_security_group.destination.id]

  parameter_group_name = aws_db_parameter_group.destination.name

  backup_retention_period = 0
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  performance_insights_enabled = true
}

resource "aws_dms_replication_subnet_group" "migration" {
  replication_subnet_group_id = "${var.instance_name}-subnet-group"
  replication_subnet_group_description = "Subnet group for DMS replication instance"
  subnet_ids = var.subnet_ids
}

resource "aws_dms_replication_instance" "migration" {
  replication_instance_id = "${var.instance_name}-replication"
  replication_instance_class = "dms.t3.micro"  # Adjust based on needs
  allocated_storage = 50
  vpc_security_group_ids = [aws_security_group.dms.id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.migration.id
  multi_az = var.highly_available
  publicly_accessible = false

  tags = {
    Name = "${var.instance_name}-dms"
  }
}

resource "aws_security_group" "dms" {
  name        = "${var.instance_name}-dms-${random_id.db_name_suffix_destination.hex}"
  description = "Security group for DMS replication instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-dms-sg"
  }
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.instance_name}-source"
  endpoint_type = "source"
  engine_name   = "postgres"

  server_name = split(":", var.source_instance_endpoint)[0]
  port        = var.database_port
  database_name = "postgres"
  username     = "postgres"
  password     = random_password.postgres.result

  extra_connection_attributes = "heartbeatFrequency=1;heartbeatEnable=Y"
}

resource "aws_dms_endpoint" "destination" {
  endpoint_id   = "${var.instance_name}-destination"
  endpoint_type = "target"
  engine_name   = "postgres"

  server_name = split(":", aws_db_instance.destination_instance.endpoint)[0]
  port        = var.database_port
  database_name = "postgres"
  username     = "postgres"
  password     = random_password.postgres.result

  extra_connection_attributes = "afterConnectScript=ALTER ROLE postgres REPLICATION;"
}

resource "aws_dms_replication_task" "migration" {
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.migration.replication_instance_arn
  replication_task_id     = "${var.instance_name}-task"
  source_endpoint_arn     = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn     = aws_dms_endpoint.destination.endpoint_arn
  table_mappings          = jsonencode({
    rules = [
      {
        rule-type = "selection"
        rule-id   = "1"
        rule-name = "all-tables"
        object-locator = {
          schema-name = "public"
          table-name  = "%"
        }
        rule-action = "include"
      }
    ]
  })

  replication_task_settings = jsonencode({
    Logging = {
      EnableLogging = true
      LogComponents = [
        {
          Id = "TRANSFORMATION"
          Severity = "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id = "SOURCE_UNLOAD"
          Severity = "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id = "TARGET_LOAD"
          Severity = "LOGGER_SEVERITY_DEFAULT"
        },
        {
          Id = "TASK_MANAGER"
          Severity = "LOGGER_SEVERITY_DEFAULT"
        }
      ]
    }
    ErrorBehavior = {
      DataErrorPolicy = "LOG_ERROR"
      DataTruncationErrorPolicy = "LOG_ERROR"
      DataErrorEscalationPolicy = "STOP_TASK"
      DataErrorEscalationCount = 0
      TableErrorPolicy = "STOP_TASK"
      TableErrorEscalationPolicy = "STOP_TASK"
      TableErrorEscalationCount = 0
      RecoverableErrorCount = -1
      RecoverableErrorInterval = 5
      RecoverableErrorThrottling = true
      RecoverableErrorThrottlingMax = 1800
      ApplyErrorDeletePolicy = "IGNORE_RECORD"
      ApplyErrorInsertPolicy = "LOG_ERROR"
      ApplyErrorUpdatePolicy = "LOG_ERROR"
      ApplyErrorEscalationPolicy = "LOG_ERROR"
      ApplyErrorEscalationCount = 0
      FullLoadIgnoreConflicts = true
    }
    ControlTablesSettings = {
      ControlSchema = "dms_control"
      HistoryTimeslotInMinutes = 5
      HistoryTableEnabled = true
      SuspendedTablesTableEnabled = true
      StatusTableEnabled = true
    }
    StreamBufferSettings = {
      StreamBufferCount = 3
      StreamBufferSizeInMB = 8
      CtrlStreamBufferSizeInMB = 5
    }
    ChangeProcessingDdlHandlingPolicy = {
      HandleSourceTableDropped = true
      HandleSourceTableTruncated = true
      HandleSourceTableAltered = true
    }
    ChangeProcessingTuning = {
      BatchApplyPreserveTransaction = true
      BatchApplyTimeoutMin = 1
      BatchApplyTimeoutMax = 30
      BatchApplyMemoryLimit = 500
      BatchSplitSize = 0
      MinTransactionSize = 1000
      CommitTimeout = 1
      MemoryLimitTotal = 1024
      MemoryKeepTime = 60
      StatementCacheSize = 50
    }
  })

  tags = {
    Name = "${var.instance_name}-migration-task"
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0.0"
    }
  }
} 