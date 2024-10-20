#!/bin/bash

# Launch Mongo with noauth
mongod --port 27017 --bind_ip_all --config "/etc/mongo/mongod.conf" --noauth &
MONGOD_PID=$!

# Wait for MongoDB to start up
echo "[DEBUG] Waiting for MongoDB to start..."
until mongosh --quiet --eval "db.runCommand({ ping: 1 })" --port 27017; do
    sleep 1
    echo "[DEBUG] Still waiting..."
done

# Initiate Replica Set
echo "[DEBUG] Initiating Replica Set"
mongosh --port 27017 --eval "rs.initiate({ _id: 'rs0', members: [{ _id: 0, host: '127.0.0.1:27017' }] })" &

# Wait for Replica Set to become ready
echo "[DEBUG] Waiting for the replica set to initialize and elect a primary..."
until mongosh --quiet --eval "rs.status().members.find(member => member.stateStr === 'PRIMARY')" --port 27017; do
    sleep 1
    echo "[DEBUG] Still waiting for primary..."
done

echo "[DEBUG] noauth launch completed"

# Create users from scripts in /data/users/
for user_script in /data/users/*.js; do
    USERNAME=$(basename "$user_script" .js)
    
    echo "[DEBUG] Checking if user '$USERNAME' exists..."
    USER_EXISTS=$(mongosh --quiet --eval "JSON.stringify(db.getSiblingDB('admin').getUser('$USERNAME'))" --port 27017)

    echo "[DEBUG] User check result: $USER_EXISTS"

    if [ "$USER_EXISTS" = "null" ]; then
        echo "[DEBUG] Creating user '$USERNAME'..."
        mongosh --port 27017 "$user_script"
    else
        echo "[DEBUG] User '$USERNAME' already exists."
    fi
done

echo "[DEBUG] User creation complete"

# Stop MongoDB without authentication
echo "[DEBUG] Stopping MongoDB..."
kill $MONGOD_PID
wait $MONGOD_PID

# Restart MongoDB with authentication enabled
echo "[DEBUG] Restarting MongoDB with authentication enabled..."
mongod --port 27017 --bind_ip_all --config "/etc/mongo/mongod.conf" --auth --keyFile "/etc/mongo/mongo-keyfile" &
MONGOD_PID=$!

# Wait for MongoDB to start up
echo "[DEBUG] Waiting for MongoDB to start..."
until mongosh --quiet --eval "db.runCommand({ ping: 1 })" --port 27017; do
    sleep 1
    echo "[DEBUG] Still waiting..."
done

# Initiate Replica Set
echo "[DEBUG] Initiating Replica Set"
mongosh --username root --password root123 --port 27017 --eval "rs.initiate({ _id: 'rs0', members: [{ _id: 0, host: '127.0.0.1:27017' }] })" &

# Wait for Replica Set to become ready
echo "[DEBUG] Waiting for the replica set to initialize and elect a primary..."
until mongosh --username root --password root123  --quiet --eval "rs.status().members.find(member => member.stateStr === 'PRIMARY')" --port 27017; do
    sleep 1
    echo "[DEBUG] Still waiting for primary..."
done

echo "[DEBUG] MONGO SHOULD BE READY"

# Wait for the mongod process to finish
wait $MONGOD_PID