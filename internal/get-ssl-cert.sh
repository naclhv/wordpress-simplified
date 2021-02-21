#!/bin/bash

full_path=$(realpath ${BASH_SOURCE[0]} | xargs dirname | xargs dirname)
project_dir=$(basename $full_path)
cd $full_path

set -o allexport
source .env
set +o allexport

cp -r internal/wp-ssl-cert/* ./
envsubst '${DOMAIN}' < ./configs/nginx-conf/nginx.conf > ./configs/nginx-conf/nginx.conf.tmp
mv ./configs/nginx-conf/nginx.conf.tmp ./configs/nginx-conf/nginx.conf

docker-compose down
docker volume rm ${project_dir}_certbot-etc
docker-compose up -d
while [[ $(docker-compose ps | grep certbot | grep -c Exit) = 0 ]]; do
    sleep 2
done
docker-compose logs certbot
docker run --rm -v ${project_dir}_certbot-etc-temp:/from -v ${project_dir}_certbot-etc:/to alpine cp -r /from/. /to
echo $(docker run --rm -v ${project_dir}_certbot-etc:/etc/letsencrypt alpine ls /etc/letsencrypt/live/${DOMAIN})
docker-compose down -v

