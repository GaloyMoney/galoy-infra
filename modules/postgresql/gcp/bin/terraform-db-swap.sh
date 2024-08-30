#!/usr/bin/env bash
set -e

dir=${1}
module_prefix=${2}

pushd ${dir}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Set the command to use, defaulting to 'terraform' if 'tofu' is not available
if command_exists tofu; then
  cmd="tofu"
else
  cmd="terraform"
fi

# Swap the instance and destination_instance
$cmd state mv "${module_prefix}.google_sql_database_instance.instance" "${module_prefix}.google_sql_database_instance.temp"
$cmd state mv "${module_prefix}.module.migration[0].google_sql_database_instance.destination_instance" "${module_prefix}.google_sql_database_instance.instance"
$cmd state mv "${module_prefix}.google_sql_database_instance.temp" "${module_prefix}.module.migration[0].google_sql_database_instance.destination_instance"

# Swap the db_name_suffix and db_name_suffix_destination
$cmd state mv "${module_prefix}.random_id.db_name_suffix" "${module_prefix}.random_id.db_name_suffix_temp"
$cmd state mv "${module_prefix}.module.migration[0].random_id.db_name_suffix_destination" "${module_prefix}.random_id.db_name_suffix"
$cmd state mv "${module_prefix}.random_id.db_name_suffix_temp" "${module_prefix}.module.migration[0].random_id.db_name_suffix_destination"

popd
