set -ex

export DESTDIR="/manageiq"
source /opt/rh/rh-ruby22/enable

cd $DESTDIR
cp certs/v2_key.dev certs/v2_key

echo "Updating DB config"
cp /database.openshift.yml $DESTDIR/config/database.yml
sed -i s/{{HOST}}/$POSTGRESQL_SERVICE_HOST/g $DESTDIR/config/database.yml
cat $DESTDIR/config/database.yml

echo "Migrating DB"
export RAILS_ENV=production
bin/rake db:migrate db:seed
bin/update

echo "Starting Memcached"
nohup /usr/bin/memcached -u root &

echo "Starting EVM"
export MIQ_SPARTAN=minimal
bundle exec rake evm:start &
tail -f log/evm.log -f log/production.log