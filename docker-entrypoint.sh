#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for Postgres
echo "Waiting for postgres..."
while ! pg_isready -h postgres -U postgres; do
  sleep 1
done
echo "PostgreSQL started"

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"
