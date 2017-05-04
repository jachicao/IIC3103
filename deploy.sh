#!/bin/bash

cd "$(dirname "$0")"

git pull

docker-compose down

docker-compose build

docker-compose up -d

docker-compose run web rake db:create

docker-compose run web rake db:migrate db:seed

exit 0