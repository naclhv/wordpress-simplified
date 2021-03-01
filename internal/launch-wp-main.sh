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

db_test="mysql --user=root --password=${MYSQL_ROOT_PASSWORD} -e \"USE ${WORDPRESS_DB_NAME}\""
while [[ $(docker-compose exec db sh -c "$db_test" | grep -c ^) != 0 ]]; do
    sleep 2
done

set_url="mysql --user=root --password=${MYSQL_ROOT_PASSWORD} ${WORDPRESS_DB_NAME} -e \
    \"UPDATE wp_options SET option_value = 'https://${DOMAIN}' \
    WHERE option_name IN ('siteurl', 'home')\""
docker-compose exec db sh -c "$set_url"

