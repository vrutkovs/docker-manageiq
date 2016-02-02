set -ex

export DESTDIR="/manageiq"
source /opt/rh/rh-ruby22/enable

cd $DESTDIR
# Store .bundle
git reset --hard
git pull --unshallow || true

cp certs/v2_key.dev certs/v2_key

echo "Migrating DB"
export RAILS_ENV=production
bin/update

echo "Starting Memcached"
nohup /usr/bin/memcached -u root &

echo "Starting EVM"
export MIQ_SPARTAN=minimal
bundle exec rake evm:start &
tail -f log/evm.log -f log/production.log