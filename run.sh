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
bundle exec rake evm:stop || true

# Store .bundle
mv .bundle /tmp/
git reset --hard
git clean -fdx
git pull --unshallow
mv /tmp/.bundle .

cp config/database.pg.yml config/database.yml
cp certs/v2_key.dev certs/v2_key
bundle install --without qpid development

echo "Initialising DB"
sudo -u postgres sh /createDB.sh
bundle exec rake db:migrate

echo "EVM has been set up"

echo "Starting EVM"
bundle exec rake evm:start
tail -f log/evm.log