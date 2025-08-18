#!/bin/bash

set -euo pipefail
cd $(dirname $0)

../public/docker-network.sh

docker rm -f xtemp
docker run --name xtemp -d \
	--network iuxt \
	-e XTEMP_STORAGE_PATH=/data \
	-e MAX_UPLOAD_SIZE=2147483648 \
	-v ./data:/data \
	--restart always \
	iuxt/xtemp:latest


../public/add_config_to_nginx.sh
