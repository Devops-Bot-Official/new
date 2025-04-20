#!/bin/bash

# Start PostgreSQL
service postgresql start

# Configure authentication
cat <<EOF > /etc/postgresql/14/main/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                trust
local   all             all                                     trust
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
EOF

# Allow remote connections
echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf

# Reload configuration
service postgresql reload

# Create database and user if they don't exist
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'devopsbot'" | grep -q 1 || \
    psql -U postgres -c "CREATE DATABASE devopsbot"

psql -U postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'devopsbot'" | grep -q 1 || \
    psql -U postgres -c "CREATE USER devopsbot WITH PASSWORD 'devopsbot'"

psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE devopsbot TO devopsbot"

echo "PostgreSQL setup completed successfully"
