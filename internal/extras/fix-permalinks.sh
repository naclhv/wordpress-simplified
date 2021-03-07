#!/bin/bash

# fixes wordpress permalinks to be like blogger's, for posts imported from blogger
# make sure that the permalinks setting in wordpress is set to custom, with:
# /%year%/%monthnum%/%postname%.html

full_path=$(realpath ${BASH_SOURCE[0]} | xargs dirname | xargs dirname | xargs dirname)
cd $full_path

docker cp internal/extras/fix.php wordpress:/var/www/html/fix.php
docker-compose exec wordpress sh -c "php -f /var/www/html/fix.php && rm /var/www/html/fix.php"

