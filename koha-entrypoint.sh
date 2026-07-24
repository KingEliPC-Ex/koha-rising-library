#!/bin/sh
set -e

echo "Custom Koha entrypoint: skipping ping check"

# Wait for DB healthcheck (Compose handles this)
echo "Database is healthy, continuing Koha startup..."

# Run Koha's real entrypoint script
exec /root/entrypoint.sh