terraform {
  backend "gcs" {
    bucket = "jcarter-dev-tf-state"
    prefix = "jcarter-dev/inception"
  }
}
