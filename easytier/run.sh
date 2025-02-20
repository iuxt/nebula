#!/bin/bash
set -euo pipefail

source .env

docker rm -f easytier
docker run --name easytier -d \
    --network host \
    -e TZ=Asia/Shanghai \
    --privileged \
    easytier/easytier:v2.2.2 \
    -c /app/config.toml
