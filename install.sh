set -ex

localedef -f UTF-8 -i en_US en_US.UTF-8

export WWWDIR="/var/www/miq"
export DESTDIR="$WWWDIR/vmdb"
REPO=${REPO:-https://github.com/ManageIQ/manageiq}
BRANCH=${BRANCH:-master}
echo "Repo: $REPO"
echo "Branch: $BRANCH"

mkdir -p $WWWDIR
git clone --depth=1 -b $BRANCH $REPO $DESTDIR
cd $DESTDIR
echo "Commit `git rev-parse HEAD`"

echo "Installing ManageIQ"
source /opt/rh/rh-ruby22/enable
export BUNDLE_WITHOUT=test:metric_fu:development
echo "gem: --no-ri --no-rdoc --no-document" > ~/.gemrc
gem install bundler
bundle config build.nokogiri --use-system-libraries

echo "Installing gems"
bundle install
cp $DESTDIR/certs/v2_key.dev $DESTDIR/certs/v2_key

echo "Running misc tasks"
echo '0' > REGION
bundle exec rake evm:compile_assets
bundle exec rake evm:compile_sti_loader

echo "EVM has been set up"