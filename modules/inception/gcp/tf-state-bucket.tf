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
  count       = local.tf_state_bucket_policy == null ? 1 : 0
  project     = local.project
  role_id     = replace("${local.name_prefix}-objects-list", "-", "_")
  title       = "List bucket Objects"
  description = "Role to _only_ list objects (not get them) from ${local.name_prefix}"
  permissions = [
    "storage.objects.list",
  ]
}

data "google_iam_policy" "tf_state_access" {
  count = local.tf_state_bucket_policy == null ? 1 : 0
  binding {
    role    = "roles/storage.admin"
    members = concat(local.inception_admins, ["serviceAccount:${local.inception_sa}"])
  }

  dynamic "binding" {
    for_each = toset(local.platform_admins)
    content {
      role = google_project_iam_custom_role.list_objects[0].id
      members = [
        binding.key
      ]
    }
  }

  dynamic "binding" {
    for_each = toset(local.platform_admins)
    content {
      role = "roles/storage.objectAdmin"
      members = [
        binding.key
      ]

      condition {
        title      = "${local.name_prefix}/platform"
        expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.name_prefix}/platform\")"
      }
    }
  }
  dynamic "binding" {
    for_each = toset(local.platform_admins)
    content {
      role = "roles/storage.objectAdmin"
      members = [
        binding.key
      ]

      condition {
        title      = "${local.name_prefix}/services"
        expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.name_prefix}/services\")"
      }
    }
  }
  dynamic "binding" {
    for_each = toset(local.platform_admins)
    content {
      role = "roles/storage.objectAdmin"
      members = [
        binding.key
      ]

      condition {
        title      = "${local.name_prefix}/galoy"
        expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.name_prefix}/galoy\")"
      }
    }
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket      = google_storage_bucket.tf_state.name
  policy_data = local.tf_state_bucket_policy == null ? data.google_iam_policy.tf_state_access.policy_data : local.tf_state_bucket_policy
}
