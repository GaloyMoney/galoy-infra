#!/bin/bash

# Prompt user for input
read -p "Enter database name: " DB_NAME
read -p "Enter new owner: " NEW_OWNER
read -p "Enter PostgreSQL connection string: " PG_CON

PSQL_CMD="psql $PG_CON -d $DB_NAME -At -c"

$PSQL_CMD "GRANT \"$NEW_OWNER\" TO \"postgres\";"
# Get list of all tables in the database
tables=$($PSQL_CMD "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

# Loop through each table and change the owner
for table in $tables; do
    $PSQL_CMD "ALTER TABLE public.\"$table\" OWNER TO \"$NEW_OWNER\";"
done

echo "Ownership of all tables in $DB_NAME has been granted to $NEW_OWNER."

#$PSQL_CMD "ALTER SCHEMA public OWNER TO \"$NEW_OWNER\";"
