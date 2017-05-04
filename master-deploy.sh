#!/bin/bash

cd "$(dirname "$0")"

git pull

docker-compose -f master-docker-compose.yml build

docker-compose -f master-docker-compose.yml down

docker-compose -f master-docker-compose.yml up -d

docker-compose -f master-docker-compose.yml exec -d web rake db:create

docker-compose -f master-docker-compose.yml exec -d web rake db:migrate db:seed

exit 0