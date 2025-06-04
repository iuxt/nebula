#!/bin/bash

set -euo pipefail
cd $(dirname $0)

../public/docker-network.sh

docker rm -f xtemp
docker run --name xtemp -d \
	--network iuxt \
	iuxt/xtemp:latest


../public/add_config_to_nginx.sh
