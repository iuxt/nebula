#!/bin/bash
set -euo pipefail
cd $(dirname $0)

podman rm -f v2ray

rm -f ../nginx/conf.d/v2ray.conf
../nginx/reload_nginx.sh

