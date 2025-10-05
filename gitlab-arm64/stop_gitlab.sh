#!/bin/bash
cd $(dirname $0)

docker rm -f gitlab-ce

rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf

../nginx/reload_nginx.sh
