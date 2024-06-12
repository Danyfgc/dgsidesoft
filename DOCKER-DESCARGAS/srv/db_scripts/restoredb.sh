DB_USER=$1
DB_NAME=$2
BACKUP_NAME=$3
pg_restore -U postgres --host localhost --port 5432 --username "$DB_USER" --dbname "$DB_NAME" -j 6 --verbose /srv/restore_backups/$BACKUP_NAME
