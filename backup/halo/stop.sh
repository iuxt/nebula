#!/bin/bash
cd $(dirname $0)

podman rm -f halo
rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf

../nginx/reload_nginx.sh