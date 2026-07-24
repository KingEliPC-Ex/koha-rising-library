#!/bin/bash
set -e

KOHA_INSTANCE=${KOHA_INSTANCE:-kohadev}
MYSQL_SERVER=${MYSQL_SERVER:-db}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-password}
MYSQL_DATABASE=${MYSQL_DATABASE:-koha_${KOHA_INSTANCE}}
MYSQL_USER=${MYSQL_USER:-koha_${KOHA_INSTANCE}}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-password}

echo "Waiting for database..."
until mysql -h "${MYSQL_SERVER}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "select 1" >/dev/null 2>&1; do
  sleep 2
done
echo "Database ready."

# Create DB + user
mysql -h "${MYSQL_SERVER}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
  "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
   CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
   GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
   FLUSH PRIVILEGES;"

# Update koha-sites.conf so koha-create uses our DB
sed -i "s/^db_host=.*/db_host=${MYSQL_SERVER}/" /etc/koha/koha-sites.conf
sed -i "s/^db_name=.*/db_name=${MYSQL_DATABASE}/" /etc/koha/koha-sites.conf
sed -i "s/^db_user=.*/db_user=${MYSQL_USER}/" /etc/koha/koha-sites.conf
sed -i "s/^db_pass=.*/db_pass=${MYSQL_PASSWORD}/" /etc/koha/koha-sites.conf

# Create Koha instance
if [ ! -d "/etc/koha/sites/${KOHA_INSTANCE}" ]; then
  echo "Creating Koha instance ${KOHA_INSTANCE}..."
  koha-create --create-db "${KOHA_INSTANCE}"
fi

# Start services
koha-zebra --start "${KOHA_INSTANCE}"
koha-plack --enable "${KOHA_INSTANCE}"
koha-plack --start "${KOHA_INSTANCE}"
service apache2 restart

touch /healthy
echo "Koha is healthy."

tail -f /var/log/koha/koha-${KOHA_INSTANCE}.log
