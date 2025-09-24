#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/docker-network.py

docker rm -f cloudreve

docker run -d \
    --name cloudreve \
    --network iuxt \
    -v ./data:/cloudreve/data \
    --restart=always \
    cloudreve/cloudreve:4.3.0

../public/add_config_to_nginx.sh
