#!/bin/bash
cd $(dirname $0)

APP_NAME=$(basename "$(pwd)")

echo $APP_NAME

docker rm -f $APP_NAME

rm -f ../nginx/conf.d/$APP_NAME.conf

../nginx/reload.sh
