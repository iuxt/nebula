#!/bin/bash
set -euo pipefail

docker rm -f cloudreve

rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf
../nginx/reload.sh

