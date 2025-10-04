#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/docker-network.py
source .env

if [ ! -e ./php_custom.ini ];then
    cp ./php.ini.example ./php_custom.ini
fi

docker rm -f wordpress
chown -R www-data:www-data ./data

docker run -d --name wordpress \
  -v ./data:/var/www/html \
  -v ./extensions:/extensions \
  --mount type=bind,source=./php_custom.ini,target=/usr/local/etc/php/conf.d/php_custom.ini \
  --env-file=.env \
  --network iuxt \
  --restart always \
  docker.io/wordpress:"${WORDPRESS_VERSION}"

../public/add_config_to_nginx.py
