#!/bin/bash

full_path=$(dirname $(realpath ${BASH_SOURCE[0]}))
cd $full_path
echo "$(date +"%Y-%m-%d %T"): $full_path/${BASH_SOURCE[0]}"

COMPOSE="/usr/local/bin/docker-compose --no-ansi"
DOCKER="/usr/bin/docker"

$COMPOSE run certbot renew --dry-run && $COMPOSE kill -s SIGHUP webserver
$DOCKER system prune -af

