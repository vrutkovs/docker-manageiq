set -ex

export DESTDIR="/var/www/miq/vmdb"
source /opt/rh/rh-ruby22/enable

cd $DESTDIR
cp certs/v2_key.dev certs/v2_key

echo "Updating DB config"
cp /database.openshift.yml $DESTDIR/config/database.yml
sed -i s/{{HOST}}/$POSTGRESQL_SERVICE_HOST/g $DESTDIR/config/database.yml
cat $DESTDIR/config/database.yml

echo "Migrating DB"
export RAILS_ENV=production
# Replace production (caching and etc.) with development snapshot
cp config/environments/{production,development}.rb
bin/rake db:migrate db:seed
bin/update

echo "Precompiling assets"
bundle exec rake evm:compile_assets
bundle exec rake evm:compile_sti_loader

echo "Setting up httpd"
mkdir -p "/var/www/miq/vmdb/log/apache"
mv /etc/httpd/conf.d/ssl.conf{,.orig}
touch /etc/httpd/conf.d/ssl.conf
mv /apache.conf /etc/httpd/conf.d/manageiq.conf


echo "Starting Memcached"
nohup /usr/bin/memcached -u root &

echo "Starting EVM"
bundle exec rake evm:start
bundle exec rake evm:status

exec /usr/sbin/apachectl -DFOREGROUND