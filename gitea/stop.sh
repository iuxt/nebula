#!/bin/bash


podman rm -f gitea

rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf
rm -f ../nginx/stream.d/gitea.conf
../nginx/run_nginx.sh
