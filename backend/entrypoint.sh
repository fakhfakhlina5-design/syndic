#!/bin/sh
set -e

echo "Attente de la disponibilité de la base de données $DB_HOST:$DB_PORT ..."
# boucle d'attente (timeout total ~ 60s)
TRIES=0
MAX_TRIES=30
SLEEP=2

while ! nc -z "$DB_HOST" "$DB_PORT" ; do
  TRIES=$((TRIES+1))
  echo "MySQL indisponible ($TRIES/$MAX_TRIES) — nouvelle tentative dans ${SLEEP}s..."
  if [ "$TRIES" -ge "$MAX_TRIES" ]; then
    echo "Timeout: la base de données n'est pas disponible après $((MAX_TRIES*SLEEP))s."
    exit 1
  fi
  sleep $SLEEP
done

echo "MySQL disponible, démarrage du backend"
exec node api/index.js
