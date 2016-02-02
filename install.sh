set -ex

localedef -f UTF-8 -i en_US en_US.UTF-8

export DESTDIR="/manageiq"
REPO=${REPO:-https://github.com/ManageIQ/manageiq}
BRANCH=${BRANCH:-master}
echo "Repo: $REPO"
echo "Branch: $BRANCH"

git clone --depth=1 -b $BRANCH $REPO $DESTDIR
cd $DESTDIR
echo "Commit `git rev-parse HEAD`"

echo "Installing ManageIQ"
source /opt/rh/rh-ruby22/enable
export BUNDLE_WITHOUT=development
echo "gem: --no-ri --no-rdoc --no-document" > ~/.gemrc
gem install bundler
bundle config build.nokogiri --use-system-libraries

echo "Initialising DB"
export RAILS_ENV=production
cp /database.openshift.yml /manageiq/config/database.yml
# Don't prepare test DB
sed -i s/test:vmdb:setup// bin/setup
bin/setup


echo "EVM has been set up"