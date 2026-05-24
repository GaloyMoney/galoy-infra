resource "google_sql_database_instance" "replica" {
  count                = local.provision_read_replica ? 1 : 0
  name                 = "${local.instance_name}-${random_id.db_name_suffix.hex}-replica"
  master_instance_name = google_sql_database_instance.instance.name

  project             = local.gcp_project
  database_version    = local.database_version
  region              = local.region
  deletion_protection = !local.destroyable

  settings {
    tier              = local.tier
    edition           = "ENTERPRISE"
    availability_type = local.highly_available ? "REGIONAL" : "ZONAL"

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

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
