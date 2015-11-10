#!/bin/bash
set -x
set -e

REPO=${REPO:-https://github.com/ManageIQ/manageiq}
BRANCH=${BRANCH:-master}

git clone --depth=1 -b $BRANCH $REPO

# Installing
cd /manageiq
bundle install --without qpid
cp config/database.pg.yml config/database.yml
cp certs/v2_key.dev certs/v2_key

# Starting manageIQ
nohup /start_postgres.sh &
nohup /usr/bin/memcached -u root &
echo "waiting for the DB to start"
sleep 5
cd /manageiq/vmdb
if [ -e /var/lib/pgsql/initialized ]
then
	echo "Reusing existing DB"
else
	echo "Init DB"
	sudo -u postgres sh /createDB.sh
	rake db:migrate
	touch /var/lib/pgsql/initialized
fi

# Make use of docker logs
ln -sf /dev/stdout log/evm.log

rake evm:start