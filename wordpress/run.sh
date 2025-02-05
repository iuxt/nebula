#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/podman-network.sh
source .env

if [ ! -e ./php_custom.ini ];then
    cp ./php_custom.ini.example ./php_custom.ini
fi


podman run -d --name wordpress \
  -v "$PWD"/wordpress_data:/var/www/html \
  -v "$PWD"/custom_extensions:/usr/local/lib/php/extensions/custom_extensions \
  --mount type=bind,source="$PWD/php_custom.ini",target=/usr/local/etc/php/conf.d/php_custom.ini \
  --env-file=.env \
  --network iuxt \
  --restart always \
  docker.io/wordpress:"${WORDPRESS_VERSION}"

../public/add_config_to_nginx.sh
