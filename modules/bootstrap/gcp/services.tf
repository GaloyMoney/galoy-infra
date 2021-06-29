locals {
  apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com"
  ]
}

resource "google_project_service" "service" {
  for_each           = toset(local.apis)
  project            = local.project
  service            = each.key
  disable_on_destroy = false
}
