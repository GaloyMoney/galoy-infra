#!/usr/bin/env bash
set -e

# Function to validate input parameters
validate_inputs() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 <directory> <database_name>"
        echo "Error: Both directory and database name are required"
        exit 1
    fi
    
    if [ ! -d "$1" ]; then
        echo "Error: Directory '$1' does not exist"
        exit 1
    fi
    
    if [ ! -f "$1/pg_connection.txt" ]; then
        echo "Error: pg_connection.txt not found in $1"
        exit 1
    fi
}

# Function to test database connection
test_connection() {
    local connection=$1
    local db_name=$2
    
    if ! psql "$connection/$db_name" -c '\q' >/dev/null 2>&1; then
        echo "Error: Could not connect to database $db_name"
        exit 1
    fi
}

validate_inputs "$1" "$2"

dir=$1
DB_NAME=$2
pushd "${dir}" || exit 1

NEW_OWNER=${DB_NAME}-user
# READ PG_CON from a file
PG_CON=$(cat pg_connection.txt)

# Test connections before proceeding
test_connection "$PG_CON" "postgres"
test_connection "$PG_CON" "$DB_NAME"

# Command for database owner change needs to connect to postgres database
PSQL_CMD_POSTGRES="psql $PG_CON/postgres -At -c"
# Command for all other operations needs to connect to target database
PSQL_CMD="psql $PG_CON/$DB_NAME -At -c"

echo "Starting ownership transfer process..."

# Perform ownership changes
$PSQL_CMD_POSTGRES "ALTER DATABASE postgres OWNER TO cloudsqlsuperuser;"
$PSQL_CMD "ALTER SCHEMA public OWNER TO cloudsqlsuperuser;"
$PSQL_CMD "GRANT \"$NEW_OWNER\" TO \"postgres\";"

# Get and process tables
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

echo "Ownership transfer process completed for $DB_NAME"
echo "Please review any warnings above"

popd || exit 1