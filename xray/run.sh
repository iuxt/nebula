#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/docker-network.py

docker rm -f xray

docker run -d --name xray \
  --network iuxt \
  --restart always \
  --mount type=bind,source="$(pwd)"/config.json,target=/app/config.json \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
  docker.io/iuxt/xray:v25.3.6

../public/add_config_to_nginx.py
