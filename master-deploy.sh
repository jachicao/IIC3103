#!/bin/bash

cd "$(dirname "$0")"

docker-compose -f master-docker-compose.yml down

cd ..

rm -rf master

git clone --branch master https://github.com/jachicao/IIC3103.git master

docker-compose -f master-docker-compose.yml build

docker-compose -f master-docker-compose.yml up -d --remove-orphans

docker-compose -f master-docker-compose.yml exec -d web rake db:create

docker-compose -f master-docker-compose.yml exec -d web rake db:migrate db:seed

exit 0