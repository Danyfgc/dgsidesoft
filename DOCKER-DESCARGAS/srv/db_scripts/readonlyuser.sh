DB_USER=$1
DB_PASS=$2
psql -U postgres -c "
    CREATE USER $DB_USER SUPERUSER password '$DB_PASS';
    ALTER USER $DB_USER SET default_transaction_read_only = ON;
";