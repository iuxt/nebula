#!/bin/bash
set -euo pipefail
cd $(dirname $0)

docker rm -f xray

rm -f ../nginx/conf.d/$(basename "$(pwd)").conf
../nginx/reload.sh

