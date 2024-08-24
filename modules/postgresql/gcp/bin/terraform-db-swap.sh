#!/usr/bin/env bash
dir=${1}
module_prefix=${2}

pushd ${1}

# we swap the instance and destination_instance
tofu state mv "${module_prefix}.google_sql_database_instance.instance" "${module_prefix}.google_sql_database_instance.temp"
tofu state mv "${module_prefix}.google_sql_database_instance.destination_instance" "${module_prefix}.google_sql_database_instance.instance"
tofu state mv "${module_prefix}.google_sql_database_instance.temp" "${module_prefix}.google_sql_database_instance.destination_instance"

# module.postgresql_migration_source.random_id.db_name_suffix
# module.postgresql_migration_source.random_id.db_name_suffix_destination

# we swap the db_name_suffix and db_name_suffix_destination
tofu state mv "${module_prefix}.random_id.db_name_suffix" "${module_prefix}.random_id.db_name_suffix_temp"
tofu state mv "${module_prefix}.random_id.db_name_suffix_destination" "${module_prefix}.random_id.db_name_suffix"
tofu state mv "${module_prefix}.random_id.db_name_suffix_temp" "${module_prefix}.random_id.db_name_suffix_destination"