#!/bin/bash

service postgresql start

echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/12/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf

service postgresql restart

gosu postgres psql -c "CREATE USER ${DJANGO_DB_USER} WITH PASSWORD '${DJANGO_DB_PASS}';"
gosu postgres psql -c "CREATE DATABASE ${DJANGO_DB_NAME} WITH OWNER ${DJANGO_DB_USER};"

gosu postgres psql -d ${DJANGO_DB_NAME} -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;"
