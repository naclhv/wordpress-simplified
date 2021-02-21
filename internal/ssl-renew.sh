#!/bin/bash

full_path=$(realpath ${BASH_SOURCE[0]} | xargs dirname | xargs dirname)
cd $full_path
echo "$(date +"%Y-%m-%d %T"): $full_path/internal/${BASH_SOURCE[0]}"

set -o allexport
source .env
set +o allexport

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
DOCKER="/usr/bin/docker"

if [[ ${CERTBOT_STAGING} = "--staging" ]]; then
  $COMPOSE run certbot renew --dry-run && $COMPOSE kill -s SIGHUP webserver
else
  $COMPOSE run certbot renew && $COMPOSE kill -s SIGHUP webserver
fi
$DOCKER system prune -af
$DOCKER volume prune -f
