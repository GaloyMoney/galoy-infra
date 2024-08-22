# ask the user for the name of postgres terraform module
echo "Enter the name of the postgres terraform module"
# we assume the module is in the structure
# module.<module_name>.google_sql_database_instance.instance
read module_name

# we swap the instance and destination_instance
terraform state mv "module.$module_name.google_sql_database_instance.instance" "module.$module_name.google_sql_database_instance.temp"
terraform state mv "module.$module_name.google_sql_database_instance.destination_instance" "module.$module_name.google_sql_database_instance.instance"
terraform state mv "module.$module_name.google_sql_database_instance.temp" "module.$module_name.google_sql_database_instance.destination_instance"

# module.postgresql_migration_source.random_id.db_name_suffix
# module.postgresql_migration_source.random_id.db_name_suffix_destination

# we swap the db_name_suffix and db_name_suffix_destination
terraform state mv "module.$module_name.random_id.db_name_suffix" "module.$module_name.random_id.db_name_suffix_temp"
terraform state mv "module.$module_name.random_id.db_name_suffix_destination" "module.$module_name.random_id.db_name_suffix"
terraform state mv "module.$module_name.random_id.db_name_suffix_temp" "module.$module_name.random_id.db_name_suffix_destination"
