#!/bin/bash
set -e

echo ">>> [INIT] Checking replica set status..."

mongosh --username "$MONGO_INITDB_ROOT_USERNAME" \
        --password "$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase "admin" \
        --quiet \
        --eval "
disableTelemetry()
"

