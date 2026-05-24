# These legacy resources were removed from the GCP PostgreSQL database
# module. The Concourse Terraform resource supports `removed` blocks as
# state-forget declarations, but not the newer `lifecycle` sub-block syntax.
# Keep resource addresses unindexed here; OpenTofu rejects keyed instance
# addresses such as `random_password.replicator[0]` in `removed.from`.
removed {
  from = random_password.big_query
}

removed {
  from = postgresql_role.big_query
}

removed {
  from = postgresql_grant.big_query_connect
}

removed {
  from = postgresql_grant.big_query_select
}

removed {
  from = google_bigquery_connection.db
}

removed {
  from = google_bigquery_connection_iam_member.user
}

removed {
  from = random_password.manual
}

removed {
  from = postgresql_role.manual
}

removed {
  from = postgresql_grant.grant_all_manual
}

removed {
  from = postgresql_grant.grant_public_schema_manual
}

removed {
  from = random_password.replicator
}

removed {
  from = postgresql_role.replicator
}

removed {
  from = postgresql_grant.grant_connect_replicator
}

removed {
  from = postgresql_grant.grant_select_replicator
}

removed {
  from = random_password.read_only
}

removed {
  from = postgresql_role.read_only
}

removed {
  from = postgresql_grant.grant_connect_read_only
}

removed {
  from = postgresql_grant.grant_usage_read_only
}

removed {
  from = postgresql_grant.grant_select_read_only
}
