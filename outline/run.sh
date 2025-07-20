#!/bin/bash
#
#
docker rm -f outline

docker run -d --name outline \
	--env-file=.env \
	-v ./data:/var/lib/outline/data \
	--network iuxt \
	docker.getoutline.com/outlinewiki/outline:latest

docker logs -f outline

