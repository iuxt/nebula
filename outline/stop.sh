#!/bin/bash
cd $(dirname $0)

APP_NAME=$(basename "$(pwd)")

echo $APP_NAME

docker rm -f $APP_NAME

../public/remove_config_from_nginx.py
