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

# remove logical replication stuff
$cmd state rm "${module_prefix}.module.migration"

# remove admin user
$cmd state rm "${module_prefix}.google_sql_user.admin"

module.postgresql_migration_source.google_sql_database_instance.replica

if $cmd state list | grep -q "${module_prefix}.google_sql_database_instance.replica"; then
  $cmd state rm "${module_prefix}.google_sql_database_instance.replica"
fi

popd
