#!/bin/bash

full_path=$(realpath ${BASH_SOURCE[0]} | xargs dirname | xargs dirname)
project_dir=$(basename $full_path)
cd $full_path

set -o allexport
source .env
set +o allexport

cp -r internal/wp-main/* ./
envsubst '${DOMAIN}' < ./configs/nginx-conf/nginx.conf > ./configs/nginx-conf/nginx.conf.tmp
mv ./configs/nginx-conf/nginx.conf.tmp ./configs/nginx-conf/nginx.conf
docker-compose up -d

