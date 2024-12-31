#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/docker-network.sh

docker run -d --name v2ray \
  --network iuxt \
  --restart always \
  --mount type=bind,source="$(pwd)"/config.json,target=/v2ray/config.json \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
  iuxt/v2ray:v5.2.0

../public/add_config_to_nginx.sh
