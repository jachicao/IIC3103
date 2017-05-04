#!/bin/bash

cd "$(dirname "$0")"

git pull

docker-compose build

docker-compose down

docker-compose up -d

docker-compose exec -d web rake db:create

docker-compose exec -d web rake db:migrate db:seed

exit 0