resource "google_sql_database_instance" "replica" {
  count                = local.provision_read_replica ? 1 : 0
  name                 = "${local.instance_name}-${random_id.db_name_suffix.hex}-replica"
  master_instance_name = google_sql_database_instance.instance.name

  project             = local.gcp_project
  database_version    = "POSTGRES_14"
  region              = local.region
  deletion_protection = !local.destroyable

  settings {
    tier              = local.tier
    availability_type = local.highly_available ? "REGIONAL" : "ZONAL"

    dynamic "database_flags" {
      for_each = local.source_db_upgradable ? [{
        name  = "cloudsql.enable_pglogical"
        value = "on"
      }] : []
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "database_flags" {
      for_each = local.max_connections > 0 ? [local.max_connections] : []
      content {
        name  = "max_connections"
        value = local.max_connections
      }
    }

    dynamic "database_flags" {
      for_each = var.enable_detailed_logging ? [{
        name  = "log_statement"
        value = "all"
        }, {
        name  = "log_lock_waits"
        value = "on"
      }] : []
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "database_flags" {
      for_each = local.replication ? ["on"] : []
      content {
        name  = "cloudsql.logical_decoding"
        value = "on"
      }
    }

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.vpc.id
    }
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
