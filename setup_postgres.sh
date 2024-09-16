#!/bin/bash

service postgresql start

echo "host all all 172.17.0.0/16 md5" >>/etc/postgresql/12/main/pg_hba.conf
echo "listen_addresses='*'" >>/etc/postgresql/12/main/postgresql.conf

service postgresql restart

gosu postgres psql -c "CREATE USER man_user WITH PASSWORD 'Y8ksKX2uqdHEepzW8s9*vX@LbANPVbrQgfgzpRgP@dJATFKCfQ6de@n3g6GYeL-yrh3Mp!CKa-hQdUM';"
gosu postgres psql -c "CREATE DATABASE man_db WITH OWNER man_user;"

gosu postgres psql -d man_db -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;"
