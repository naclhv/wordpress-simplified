#!/bin/bash

full_path=$(dirname $(realpath ${BASH_SOURCE[0]}))
project_dir=$(basename $full_path) 
cd $full_path

set -o allexport
source .env
set +o allexport

#get ssl certificates
cp -r wp-ssl-cert/* ./
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

#start up the actual wordpress site
cp -r wp-permanent/* ./
envsubst '${DOMAIN}' < ./configs/nginx-conf/nginx.conf > ./configs/nginx-conf/nginx.conf.tmp
mv ./configs/nginx-conf/nginx.conf.tmp ./configs/nginx-conf/nginx.conf
docker-compose up -d

#schedule cron jobs
chmod +x ssl-renew.sh
line="*/5 * * * * ${full_path}/ssl-renew.sh >> /var/log/cron.log 2>&1"
crontab -u ${USER} -l | grep -v "${full_path}/ssl-renew.sh"  | crontab -u ${USER} -
(crontab -u ${USER} -l; echo "$line" ) | crontab -u ${USER} -

chmod +x backup-site.sh
line="*/5 * * * * ${full_path}/backup-site.sh >> /var/log/cron.log 2>&1"
crontab -u ${USER} -l | grep -v "${full_path}/backup-site.sh"  | crontab -u ${USER} -
(crontab -u ${USER} -l; echo "$line" ) | crontab -u ${USER} -
