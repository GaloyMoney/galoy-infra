#!/bin/bash

# Variables
DB_NAME="your_database_name"
NEW_OWNER="test-user"
PSQL_CMD="psql -d $DB_NAME -At -c"

# Get list of all tables in the database
tables=$($PSQL_CMD "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

# Loop through each table and change the owner
for table in $tables; do
    psql $PG_CON -At -c  "ALTER TABLE public.\"$table\" OWNER TO \"$NEW_OWNER\";"
done

echo "Ownership of all tables in $DB_NAME has been granted to $NEW_OWNER."


# ACTUAL COMMANDS:
psql $PG_CON -At -c  "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"
NEW_OWNER="cala-user"
for table in $tables; do
    psql $PG_CON -At -c  "ALTER TABLE public.\"$table\" OWNER TO \"$NEW_OWNER\";"
done
psql $PG_CON -At -c  "GRANT \"cala-user\" TO \"postgres\";"
psql $PG_CON -At -c  "ALTER SCHEMA public OWNER TO \"$NEW_OWNER\";"
