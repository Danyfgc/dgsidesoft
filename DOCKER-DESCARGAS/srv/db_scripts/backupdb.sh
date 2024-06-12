DB_NAME=$1
pg_dump -p 5432 -U postgres -F c -v -f /srv/restore_backups/${DB_NAME}_$(date +%Y%m%d_%H%M).dmp $DB_NAME