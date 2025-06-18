#!/bin/bash
cd $(dirname $0)


docker rm -f gitea

rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf
rm -f ../nginx/stream.d/gitea.conf
../nginx/run.sh
