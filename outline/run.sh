#!/bin/bash

docker rm -f outline

mkdir ./data
chown -R 1001:1001 ./data

docker run -d --name outline \
	--env-file=.env \
	-v ./data:/var/lib/outline/data \
	--network iuxt \
	docker.getoutline.com/outlinewiki/outline:latest

../public/add_config_to_nginx.sh

docker logs -f outline

