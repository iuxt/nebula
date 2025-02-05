#!/bin/bash
set -euo pipefail

source .env

docker rm -f easytier
docker run --name easytier -d \
    --network host \
    -e TZ=Asia/Shanghai \
    --privileged \
    easytier/easytier:v2.2.0 \
    --ipv4 10.233.233.1 --network-name ${NETWORK_NAME} --network-secret ${NETWORK_SECRET} --vpn-portal wg://0.0.0.0:11013/10.14.14.0/24
