#!/bin/bash
set -euo pipefail
cd $(dirname $0)

docker rm -f v2ray

rm -f ../nginx/conf.d/$(basename "$(pwd)").conf
../nginx/reload.py

