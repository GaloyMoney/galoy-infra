resource "google_project_service" "iam" {
  project = local.project
  service = "iam.googleapis.com"
}

resource "google_project_service" "cloudresourcemanager" {
  project = local.project
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute" {
  project = local.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project = local.project
  service = "container.googleapis.com"
}

resource "google_project_service" "cloudkms" {
  project = local.project
  service = "cloudkms.googleapis.com"
}
