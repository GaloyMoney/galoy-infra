gcp_project              = "cross-org-debug"
inception_sa             = "guatt-z-inception-tf@cross-org-debug.iam.gserviceaccount.com"
name_prefix              = "guatt-z"
tf_state_bucket_location = "US-EAST1"
tf_state_bucket_name     = "guatt-z-tf-state"
users = [
  {
    id        = "user:sandipan@galoy.io"
    inception = true
    platform  = true
    logs      = true
  },
  {
    id        = "user:justin@galoy.io"
    inception = true
    platform  = true
    logs      = true
  }
]
