#!/bin/bash
set -euo pipefail

docker rm -f easytier
docker run --name easytier -d \
    --network host \
    -e TZ=Asia/Shanghai \
    --mount type=bind,source=./config.toml,target=/app/config.toml,readonly \
    --privileged \
    --restart=always \
    easytier/easytier:v2.3.1 \
    -c /app/config.toml
