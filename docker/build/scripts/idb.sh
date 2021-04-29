#!/bin/sh

set -x

# try to load the schema
export HOME=/opt/idb
export RAILS_ENV=production
#sudo -E -u idb bundle exec rake db:schema:load --trace || true
sudo -E -u idb bundle exec rake db:migrate --trace || true
sudo -E -u idb bundle exec rake assets:precompile --trace || true

apachectl -D FOREGROUND &

tail -q -f /var/log/apache2/*.log

