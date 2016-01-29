#!/bin/bash
set -e

export DESTDIR="/manageiq"

source /opt/rh/rh-ruby22/enable

echo "Starting Postgres and memcached"
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
cp config/database.pg.yml config/database.yml
cp certs/v2_key.dev certs/v2_key
bundle install --without qpid development

echo "Initialising DB"
sudo -u postgres sh /createDB.sh
bundle exec rake db:migrate
bundle exec rake db:seed

bin/setup
echo "EVM has been set up"