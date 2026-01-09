#!/bin/bash
set -e

echo ">>> [INIT] Checking application user in MongoDB..."

mongosh --username "$MONGO_INITDB_ROOT_USERNAME" \
        --password "$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase "admin" \
        --quiet \
        --eval "
const dbName='${MONGO_APP_DB}';
const user='${MONGO_APP_USER}';
const pwd='${MONGO_APP_PASS}';

db = db.getSiblingDB(dbName);

try {
  if (db.getUser(user)) {
    print('>>> [INFO] User \"' + user + '\" already exists in DB ' + dbName);
  } else {
    print('>>> [WARN] User \"' + user + '\" does not exist, creating...');
    const result = db.createUser({
      user: user,
      pwd: pwd,
      roles: [{ role: 'readWrite', db: dbName }]
    });
    if (result.ok === 1) {
      print('>>> [SUCCESS] User \"' + user + '\" created successfully in DB ' + dbName);
    } else {
      print('>>> [ERROR] Failed to create user \"' + user + '\": ' + tojson(result));
    }
  }

  if (db.getCollectionNames().length === 0) {
    print('>>> [WARN] No collections found in DB ' + dbName + '. Creating dummy collection...');
    db.createCollection('init_dummy');
    db.init_dummy.insertOne({ createdAt: new Date(), note: 'DB initialized by init script' });
    print('>>> [SUCCESS] Database ' + dbName + ' initialized with dummy collection.');
  } else {
    print('>>> [INFO] Database ' + dbName + ' already contains collections.');
  }
} catch (e) {
  print('>>> [ERROR] Exception while creating user or initializing DB: ' + e);
}
"
