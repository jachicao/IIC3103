#!/bin/bash

cd "$(dirname "$0")"

git checkout master

git pull

docker-compose -f master-docker-compose.yml build

docker-compose -f master-docker-compose.yml down

docker-compose -f master-docker-compose.yml run web /bin/bash -c "export SECRET_KEY_BASE=$(rake secret) && run_cmd"

docker-compose -f master-docker-compose.yml up -d --remove-orphans

docker-compose -f master-docker-compose.yml exec -d web rake db:create

docker-compose -f master-docker-compose.yml exec -d web rake db:migrate db:seed

exit 0