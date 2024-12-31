#!/bin/bash

app=$(basename "$(pwd)")
echo "$app"


if [ ! -e ./custom_nginx.conf ];then
  /bin/cp nginx.conf custom_nginx.conf
fi

/bin/cp -f custom_nginx.conf ../nginx/conf.d/"$app".conf
../nginx/reload_nginx.sh