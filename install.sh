#!/bin/bash
set -e

export DESTDIR="/manageiq"

echo "Starting Postgres and memcached"
nohup /start_postgres.sh &
nohup /usr/bin/memcached -u root &
echo "waiting for the DB to start"
sleep 5

if [ ! -d $DESTDIR ]; then
	REPO=${REPO:-https://github.com/ManageIQ/manageiq}
	BRANCH=${BRANCH:-master}

	echo "Repo: $REPO"
	echo "Branch: $BRANCH"

	git clone --depth=1 -b $BRANCH $REPO $DESTDIR
	cd $DESTDIR
	echo "Commit `git rev-parse HEAD`"

else
	cd $DESTDIR
	bundle exec rake evm:stop || true

	git reset --hard
	git clean -fdx
	git pull --unshallow

fi

echo "Installing ManageIQ"
cp config/database.pg.yml config/database.yml
cp certs/v2_key.dev certs/v2_key
bundle config build.nokogiri --use-system-libraries
bundle install --without qpid development

echo "Initialising DB"
sudo -u postgres sh /createDB.sh
bundle exec rake db:migrate

echo "EVM has been set up"

echo "Starting EVM"
bundle exec rake evm:start
tail -f log/evm.log