#!/bin/bash

cd "$(dirname "$0")"

git checkout develop

git pull

docker-compose -f develop-docker-compose.yml build

docker-compose -f develop-docker-compose.yml down

docker-compose -f develop-docker-compose.yml up -d --remove-orphans

docker-compose -f develop-docker-compose.yml exec -d develop-web rake db:create

docker-compose -f develop-docker-compose.yml exec -d develop-web rake db:migrate db:reset

exit 0