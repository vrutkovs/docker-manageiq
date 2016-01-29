#!/bin/bash
set -e

export DESTDIR="/manageiq"
source /opt/rh/rh-ruby22/enable

echo "Starting Postgres and memcached"
nohup /start_postgres.sh &
nohup /usr/bin/memcached -u root &
echo "waiting for the DB to start"
sleep 5

cd $DESTDIR
# Store .bundle
mv .bundle /tmp/
git reset --hard
git pull --unshallow || true
mv /tmp/.bundle .

cp config/database.pg.yml config/database.yml
cp certs/v2_key.dev certs/v2_key

echo "Migrating DB"
export RAILS_ENV=production
bin/update

echo "Starting EVM"
export MIQ_SPARTAN=minimal
bundle exec rake evm:start
bundle exec bin/rails s --binding=0.0.0.0
tail -f log/evm.log -f log/production.log