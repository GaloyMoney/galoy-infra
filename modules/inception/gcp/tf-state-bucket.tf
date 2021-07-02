resource "google_storage_bucket" "tf_state" {
  name                        = local.tf_state_bucket_name
  project                     = local.project
  location                    = local.tf_state_bucket_location
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_project_iam_custom_role" "list_objects" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-objects-list", "-", "_")
  title       = "List bucket Objects"
  description = "Role to _only_ list objects (not get them)"
  permissions = [
    "storage.objects.list",
  ]
}

data "google_iam_policy" "tf_state_access" {
  binding {
    role    = "roles/storage.admin"
    members = local.inception_admins
  }

  binding {
    role = google_project_iam_custom_role.list_objects.id
    members = [
      "serviceAccount:${var.inception_sa}",
      "serviceAccount:${google_service_account.bastion.email}",
    ]
  }

  binding {
    role = "roles/storage.objectAdmin"
    members = [
      "serviceAccount:${var.inception_sa}",
    ]

    condition {
      title      = "${local.name_prefix}/inception"
      expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.name_prefix}/inception\")"
    }
  }

  binding {
    role = "roles/storage.objectAdmin"
    members = [
      "serviceAccount:${google_service_account.bastion.email}",
    ]

    condition {
      title      = "${local.name_prefix}/platform"
      expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.name_prefix}/platform\")"
    }
  }

  binding {
    role = "roles/storage.objectAdmin"
    members = [
      "serviceAccount:${google_service_account.bastion.email}",
    ]

    condition {
      title      = "${local.name_prefix}/services"
      expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.name_prefix}/services\")"
    }
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket      = google_storage_bucket.tf_state.name
  policy_data = data.google_iam_policy.tf_state_access.policy_data
}
