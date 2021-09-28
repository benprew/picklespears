#!/bin/sh

set -e

host=$1
shift
cmd="$@"

until psql "$DATABASE_URL"; do
      >&2 echo "Postgres is unavailable - sleeping"
      sleep 2
done

>&2 echo "Postgres is up - executing command: $cmd"
exec "$cmd"
