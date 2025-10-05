#!/bin/bash
cd $(dirname $0)

docker rm -f jenkins
rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf

../nginx/reload_nginx.sh