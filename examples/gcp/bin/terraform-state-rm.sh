# ask the user for the name of postgres terraform module
echo "Enter the name of the postgres terraform module"
# we assume the module is in the structure
# module.<module_name>.google_sql_database_instance.instance
read module_name

# remove logical replication stuff
terraform state rm "module.$module_name.postgresql_extension.pglogical"
terraform state rm "module.$module_name.postgresql_grant.grant_connect_db_migration_user"
terraform state rm "module.$module_name.postgresql_grant.grant_select_table_pglogical_schema_migration_user"
terraform state rm "module.$module_name.postgresql_grant.grant_select_table_public_schema_migration_user"
terraform state rm "module.$module_name.postgresql_grant.grant_usage_pglogical_schema_migration_user"
terraform state rm "module.$module_name.postgresql_grant.grant_usage_pglogical_schema_public_user"
terraform state rm "module.$module_name.postgresql_grant.grant_usage_public_schema_migration_user"

# remove the old instance from state to prevent conflicts
terraform state rm "module.$module_name.google_sql_database_instance.destination_instance"
terraform state rm "module.$module_name.random_id.db_name_suffix_destination"

# remove connection profile
terraform state rm "module.$module_name.google_database_migration_service_connection_profile.connection_profile"

# remove migration user
terraform state rm "module.$module_name.postgresql_role.migration"
terraform state rm "module.$module_name.random_password.migration"

# remove admin user
terraform state rm "module.$module_name.google_sql_user.admin"

