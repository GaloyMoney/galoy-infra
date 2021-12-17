terraform {
  backend "gcs" {
    bucket = "guatt-z-tf-state"
    prefix = "guatt-z/inception"
  }
}
