#!/bin/bash
set -e

# Load env
. /etc/environment 2>/dev/null || true
. /root/.bashrc 2>/dev/null || true

KOHA_INSTANCE=${KOHA_INSTANCE:-kohadev}
MYSQL_SERVER=${MYSQL_SERVER:-db}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-Rising0605}
MYSQL_DATABASE=${MYSQL_DATABASE:-koha_${KOHA_INSTANCE}}
MYSQL_USER=${MYSQL_USER:-koha_${KOHA_INSTANCE}}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-Rising0605}

# Wait for DB to be reachable
echo "Waiting for database ${MYSQL_SERVER}..."
for i in $(seq 1 60); do
  if mysql -h "${MYSQL_SERVER}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "select 1" >/dev/null 2>&1; then
    echo "Database reachable"
    break
  fi
  echo "DB not ready yet, retrying..."
  sleep 2
done

# Create database and user if not exists
echo "Ensuring database and user exist..."
mysql -h "${MYSQL_SERVER}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -h "${MYSQL_SERVER}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}'; GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%'; FLUSH PRIVILEGES;"

# Create Koha instance if not present
if [ ! -d "/etc/koha/sites/${KOHA_INSTANCE}" ]; then
  echo "Creating Koha instance ${KOHA_INSTANCE}..."
  koha-create --create-db --request-db --dbhost="${MYSQL_SERVER}" --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" "${KOHA_INSTANCE}"
fi

# Start Zebra if installed
if command -v zebra >/dev/null 2>&1; then
  echo "Starting Zebra..."
  service zebra start || true
fi

# Start Plack (backend)
if [ -f /usr/share/koha/bin/plack.psgi ]; then
  echo "Starting Plack on 8080..."
  start-stop-daemon --start --background --chuid koha --exec /usr/bin/starman -- -p 8080 /usr/share/koha/bin/plack.psgi || true
fi

# Start Apache for staff and OPAC
echo "Starting Apache..."
service apache2 restart || true

# Mark healthy
touch /healthy
echo "Koha is healthy"

# Keep container running and show logs
tail -f /var/log/koha/koha-*.log /var/log/apache2/*.log 2>/dev/null || tail -f /dev/null
