DB_NAME=$1
NEW_DB_NAME=$2
psql -U postgres -c "
    SELECT *, pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '$DB_NAME';
    REVOKE CONNECT ON DATABASE $DB_NAME FROM PUBLIC, tad;
    ALTER DATABASE $DB_NAME RENAME TO $NEW_DB_NAME;
"