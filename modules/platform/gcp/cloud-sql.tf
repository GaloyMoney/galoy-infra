module "shared_pg" {
  count  = local.deploy_shared_pg ? 1 : 0
  source = "./cloud-sql"

  project              = local.project
  vpc_id               = data.google_compute_network.vpc.id
  region               = local.region
  instance_name        = "${local.name_prefix}-shared-pg"
  destroyable_postgres = var.destroyable_postgres
  highly_available     = local.pg_ha
  postgres_tier        = local.postgres_tier
}
