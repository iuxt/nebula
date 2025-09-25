#!/bin/bash
cd $(dirname $0)

../public/docker-network.py

docker rm -f gitea

# https://docs.gitea.com/installation/install-with-docker
#    -m 512M --memory-swap=768M \

source .env

docker run -d \
    --name gitea \
    --network iuxt \
    -e USER_UID=1000 \
    -e USER_GID=1000 \
    --env-file=.env \
    --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
    -v ./gitea-data:/data \
    --restart=always \
    docker.io/gitea/gitea:${GITEA_VERSION}

cp -f ./nginx-stream.conf ../nginx/stream.d/gitea.conf
../nginx/run.sh
../public/add_config_to_nginx.py
