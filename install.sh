#!/bin/bash
set -e
localedef -f UTF-8 -i en_US en_US.UTF-8

export DESTDIR="/manageiq"

source /opt/rh/rh-ruby22/enable

echo "Starting Postgres and memcached"

echo "fsync=off" > /var/lib/pgsql/data/postgresql.conf
echo "full_page_writes=off" >> /var/lib/pgsql/data/postgresql.conf
echo "synchronous_commit=off" >> /var/lib/pgsql/data/postgresql.conf
echo "listen_addresses = '*'" >> /var/lib/pgsql/data/postgresql.conf
echo "local all all trust" > /var/lib/pgsql/data/pg_hba.conf
echo "host all all 0.0.0.0/0 trust" >> /var/lib/pgsql/data/pg_hba.conf

nohup /start_postgres.sh &
nohup /usr/bin/memcached -u root &
echo "waiting for the DB to start"
sleep 5

REPO=${REPO:-https://github.com/ManageIQ/manageiq}
BRANCH=${BRANCH:-master}

echo "Repo: $REPO"
echo "Branch: $BRANCH"

git clone --depth=1 -b $BRANCH $REPO $DESTDIR
cd $DESTDIR
echo "Commit `git rev-parse HEAD`"

echo "Installing ManageIQ"
export BUNDLE_WITHOUT=development
echo "gem: --no-ri --no-rdoc --no-document" > ~/.gemrc
bundle config build.nokogiri --use-system-libraries

echo "Initialising DB"
psql -c "CREATE USER root SUPERUSER PASSWORD 'smartvm';" -U postgres
for i in test production development;do createdb vmdb_$i;done
psql -c "alter database vmdb_production owner to root"
echo "1" > REGION
export RAILS_ENV=production
bin/setup || true

echo "EVM has been set up"