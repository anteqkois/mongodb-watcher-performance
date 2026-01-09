#!/bin/bash
set -e

echo ">>> [INIT] Waiting for MongoDB to be ready..."

# Host resolution logic:
# Use 127.0.0.1 to allow connection from host without /etc/hosts modification
HOSTNAME_TO_USE="127.0.0.1"

# Loop until we can connect
until mongosh --host mongodb --port 27017 --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase "admin" --quiet --eval "db.adminCommand('ping')"; do
  echo ">>> [INIT] MongoDB unavailable - sleeping"
  sleep 2
done

echo ">>> [INIT] MongoDB is up! Checking replica set status..."

mongosh --host mongodb --port 27017 \
        --username "$MONGO_INITDB_ROOT_USERNAME" \
        --password "$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase "admin" \
        --quiet \
        --eval "
try {
  const status = rs.status();
  if (status.ok === 1 && status.myState !== 0) {
    print('>>> [INFO] Replica set already initialized. State: ' + status.myState);
    print('>>> [INFO] Current members: ' + tojson(status.members));
  } else {
    print('>>> [WARN] Replica set not initialized, proceeding...');
    const result = rs.initiate({
      _id: '${MONGO_REPLSET:-rs0}',
      members: [{ _id: 0, host: '${HOSTNAME_TO_USE}:27017', priority: 2 }]
    });
    if (result.ok === 1) {
      print('>>> [SUCCESS] Replica set initialized successfully with host ${HOSTNAME_TO_USE}:27017');
    } else {
      print('>>> [ERROR] Replica set initialization failed: ' + tojson(result));
    }
  }
} catch (e) {
  print('>>> [WARN] rs.status() failed (expected if not init). Error: ' + e);
  const result = rs.initiate({
    _id: '${MONGO_REPLSET:-rs0}',
    members: [{ _id: 0, host: '${HOSTNAME_TO_USE}:27017', priority: 2 }]
  });
  if (result.ok === 1) {
    print('>>> [SUCCESS] Replica set initialized successfully with host ${HOSTNAME_TO_USE}:27017');
  } else {
    print('>>> [ERROR] Replica set initialization failed: ' + tojson(result));
  }
}
"
