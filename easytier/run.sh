#!/bin/bash
set -euo pipefail
cd $(dirname $0)

docker rm -f easytier
docker run --name easytier -d \
    --network host \
    -e TZ=Asia/Shanghai \
    --mount type=bind,source=./config.toml,target=/app/config.toml,readonly \
    --privileged \
    --restart=always \
    easytier/easytier:v2.4.3 \
    -c /app/config.toml
