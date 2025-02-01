#!/bin/bash
set -euo pipefail
cd $(dirname $0)

podman rm -f cloudreve aria2

rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf
../nginx/reload_nginx.sh

