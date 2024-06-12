DB_USER=$1
DB_NAME=$2
createdb -U postgres -O $DB_USER $DB_NAME