#!/bin/bash

full_path=$(dirname $(realpath ${BASH_SOURCE[0]}))
project_dir=$(basename $full_path)
cd $full_path

set -o allexport
source .env
set +o allexport

bash internal/restore-content.sh
bash internal/get-ssl-cert.sh
bash internal/launch-wp-main.sh
bash internal/schedule-cron.sh

