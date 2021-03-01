#!/bin/bash

full_path=$(realpath ${BASH_SOURCE[0]} | xargs dirname | xargs dirname)
project_dir=$(basename $full_path)
cd $full_path

set -o allexport
source .env
set +o allexport

chmod +x internal/renew-ssl.sh
line="${RENEW_CRONSTR} ${full_path}/internal/renew-ssl.sh >> /var/log/cron.log 2>&1"
crontab -u ${USER} -l | grep -v "${full_path}/internal/renew-ssl.sh"  | crontab -u ${USER} -
(crontab -u ${USER} -l; echo "$line" ) | crontab -u ${USER} -

chmod +x backup-site.sh
line="${BACKUP_CRONSTR} ${full_path}/backup-site.sh >> /var/log/cron.log 2>&1"
crontab -u ${USER} -l | grep -v "${full_path}/backup-site.sh"  | crontab -u ${USER} -
(crontab -u ${USER} -l; echo "$line" ) | crontab -u ${USER} -
