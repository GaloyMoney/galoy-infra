#!/usr/bin/env bash
dir=${1}
module_prefix=${2}

pushd ${1}

# remove logical replication stuff
tofu state rm "${module_prefix}.postgresql_extension.pglogical"
tofu state rm "${module_prefix}.postgresql_grant.grant_connect_db_migration_user"
tofu state rm "${module_prefix}.postgresql_grant.grant_select_table_pglogical_schema_migration_user"
tofu state rm "${module_prefix}.postgresql_grant.grant_select_table_public_schema_migration_user"
tofu state rm "${module_prefix}.postgresql_grant.grant_usage_pglogical_schema_migration_user"
tofu state rm "${module_prefix}.postgresql_grant.grant_usage_pglogical_schema_public_user"
tofu state rm "${module_prefix}.postgresql_grant.grant_usage_public_schema_migration_user"

# remove the old instance from state to prevent conflicts
tofu state rm "${module_prefix}.google_sql_database_instance.destination_instance"
tofu state rm "${module_prefix}.random_id.db_name_suffix_destination"

# remove connection profile
tofu state rm "${module_prefix}.google_database_migration_service_connection_profile.connection_profile"

# remove migration user
tofu state rm "${module_prefix}.postgresql_role.migration"
tofu state rm "${module_prefix}.random_password.migration"

# remove admin user
tofu state rm "${module_prefix}.google_sql_user.admin"