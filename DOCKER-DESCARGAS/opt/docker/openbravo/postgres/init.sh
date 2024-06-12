psql -U postgres -c "CREATE USER $MAIN_USER WITH SUPERUSER PASSWORD '$MAIN_PASS';"
sed -i -e"s/^datestyle = 'iso, mdy'.*$/datestyle = 'iso, dmy'/" /var/lib/postgresql/data/postgresql.conf
