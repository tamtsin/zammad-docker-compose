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

if [ "$1" = 'zammad-railsserver' ]; then

  # wait for postgres process coming up on zammad-postgresql
  until (echo > /dev/tcp/${DATABASE_HOST}/5432) &> /dev/null; do
    echo "zammad railsserver waiting for postgresql server to be ready..."
    sleep 5
  done

  echo "railsserver can access postgresql server now..."

  cd ${ZAMMAD_DIR}
  # bundle exec rails r "Setting.set('es_url', 'http://zammad-elasticsearch:9200')"
  bundle exec rake db:migrate &> /dev/null

  if [ $? != 0 ]; then
    echo "creating db & searchindex..."
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    # bundle exec rake searchindex:rebuild
  fi

  # delete logs
  find ${ZAMMAD_DIR}/log -iname *.log -exec rm {} \;

  # run zammad
  echo "starting zammad..."
  echo "zammad will be accessable on http://localhost in some seconds"

  if [ "${RAILS_SERVER}" == "puma" ]; then
    bundle exec puma -b tcp://0.0.0.0:3000 -e ${RAILS_ENV}
  elif [ "${RAILS_SERVER}" == "unicorn" ]; then
    bundle exec unicorn -p 3000 -c config/unicorn.rb -E ${RAILS_ENV}
  fi

fi
