#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/docker-network.sh

docker run -d --name xray \
  --network iuxt \
  --restart always \
  --mount type=bind,source="$(pwd)"/config.json,target=/app/config.json \
  --mount type=bind,source=../nginx/conf.d/xray-fallback.sock,target=/app/xray-fallback.sock \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
  docker.io/iuxt/xray:v25.3.6

../public/add_config_to_nginx.sh
