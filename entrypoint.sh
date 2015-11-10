#!/bin/bash
set -e

REPO=${REPO:-https://github.com/ManageIQ/manageiq}
BRANCH=${BRANCH:-master}

echo "Repo: $REPO"
echo "Branch: $BRANCH"

git clone --depth=1 -b $BRANCH $REPO manageiq

echo "Installing ManageIQ"
cd /manageiq
bundle install --without qpid
cp config/database.pg.yml config/database.yml
cp certs/v2_key.dev certs/v2_key

echo "Installing Postgres and memcached"
nohup /start_postgres.sh &
nohup /usr/bin/memcached -u root &
echo "waiting for the DB to start"
sleep 5

if [ -e /var/lib/pgsql/initialized ]
then
	echo "Reusing existing DB"
else
	echo "Initialising DB"
	sudo -u postgres sh /createDB.sh
	rake db:migrate
	touch /var/lib/pgsql/initialized
fi

echo "Starting EVM"
ln -sf /dev/stdout log/evm.log
rake evm:start
