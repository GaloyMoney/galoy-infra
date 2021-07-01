resource "google_storage_bucket" "tf_state" {
  name     = "${local.name_prefix}-tf-state"
  project  = local.project
  location = local.tf_state_bucket_location

  versioning {
    enabled = true
  }
}

# resource "google_project_iam_custom_role" "list_objects" {
#   role_id     = replace("${local.name_prefix}-objects-list", "-", "_")
#   title       = "List bucket Objects"
#   description = "Role to _only_ list objects (not get them)"
#   permissions = [
#     "storage.objects.list",
#   ]
# }

# data "google_iam_policy" "tf_state_access" {
#   binding {
#     role    = "roles/storage.admin"
#     members = [for email in local.inception_users : "user:${email}"]
#   }

#   binding {
#     role = google_project_iam_custom_role.list_objects.id
#     members = [
#       "serviceAccount:${var.inception_sa}",
#       "serviceAccount:${google_service_account.bastion.email}",
#     ]
#   }

#   binding {
#     role = "roles/storage.objectAdmin"
#     members = [
#       "serviceAccount:${var.inception_sa}",
#     ]

#     condition {
#       title      = "${local.project}/inception"
#       expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.project}/inception\")"
#     }
#   }

#   binding {
#     role = "roles/storage.objectAdmin"
#     members = [
#       "serviceAccount:${google_service_account.bastion.email}",
#     ]

#     condition {
#       title      = "${local.project}/platform"
#       expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.project}/platform\")"
#     }
#   }

#   binding {
#     role = "roles/storage.objectAdmin"
#     members = [
#       "serviceAccount:${google_service_account.bastion.email}",
#     ]

#     condition {
#       title      = "${local.project}/services"
#       expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.tf_state.name}/objects/${local.project}/services\")"
#     }
#   }
# }

# resource "google_storage_bucket_iam_policy" "policy" {
#   bucket      = google_storage_bucket.tf_state.name
#   policy_data = data.google_iam_policy.tf_state_access.policy_data
# }
