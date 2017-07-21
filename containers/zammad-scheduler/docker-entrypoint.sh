#!/bin/bash

set -u

# get and set Environment variable
DATABASE_HOST=$DATABASE_HOST
DATABASE_NAME=$DATABASE_NAME
DATABASE_USERNAME=$DATABASE_USERNAME
DATABASE_PASSWORD=$DATABASE_PASSWORD

cd ${ZAMMAD_DIR}
# set postgresql database adapter
sed -e 's#.*adapter: postgresql#  adapter: postgresql#g' -e 's#.*database:.*#  database: '${DATABASE_NAME}'#g' -e 's#.*username:.*#  username: '${DATABASE_USERNAME}'#g' -e 's#.*password:.*#  password: '${DATABASE_PASSWORD}' \n  host: '${DATABASE_HOST}'\n#g' < config/database.yml.pkgr > config/database.yml

if [ "$1" = 'zammad-scheduler' ]; then
  # wait for zammad process coming up
  until (echo > /dev/tcp/zammad-railsserver/3000) &> /dev/null; do
    echo "scheduler waiting for zammads railsserver to be ready..."
    sleep 2
  done

  echo "scheduler can access raillsserver now..."

  # start scheduler
  cd ${ZAMMAD_DIR}
  bundle exec script/scheduler.rb run
fi
