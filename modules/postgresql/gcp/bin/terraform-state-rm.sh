#!/usr/bin/env bash
dir=${1}
module_prefix=${2}

pushd ${1}

# remove logical replication stuff
tofu state rm "${module_prefix}.migration"

# remove admin user
tofu state rm "${module_prefix}.google_sql_user.admin"
popd
