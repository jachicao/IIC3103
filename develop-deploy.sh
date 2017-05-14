#!/bin/bash

cd "$(dirname "$0")"

docker-compose -f develop-docker-compose.yml down

cd ..

rm -rf develop

git clone --branch develop https://github.com/jachicao/IIC3103.git develop

cd develop

docker-compose -f develop-docker-compose.yml build

docker-compose -f develop-docker-compose.yml up -d --remove-orphans

docker-compose -f develop-docker-compose.yml exec -d develop-web rake db:create

docker-compose -f develop-docker-compose.yml exec -d develop-web rake db:migrate db:seed

exit 0