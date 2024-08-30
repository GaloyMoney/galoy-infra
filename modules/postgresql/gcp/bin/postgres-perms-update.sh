#!/usr/bin/env bash
set -e

dir=${1}
DB_NAME=${2}

pushd ${dir}

NEW_OWNER=${DB_NAME}-user
# READ PG_CON from a file
PG_CON=$(cat pg_connection.txt)

PSQL_CMD="psql $PG_CON -At -c"

$PSQL_CMD "ALTER DATABASE postgres OWNER TO cloudsqlsuperuser;"
$PSQL_CMD "ALTER SCHEMA public OWNER TO cloudsqlsuperuser;"

$PSQL_CMD "GRANT \"$NEW_OWNER\" TO \"postgres\";"
# Get list of all tables in the database
tables=$($PSQL_CMD "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

# Loop through each table and change the owner
for table in $tables; do
    $PSQL_CMD "ALTER TABLE public.\"$table\" OWNER TO \"$NEW_OWNER\";"
done

# Get list of all sequences in the database
sequences=$($PSQL_CMD "SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public';")

# Loop through each sequence and change the owner
for sequence in $sequences; do
    $PSQL_CMD "ALTER SEQUENCE public.\"$sequence\" OWNER TO \"$NEW_OWNER\";"
done

echo "Ownership of all tables in $DB_NAME has been granted to $NEW_OWNER."

popd
