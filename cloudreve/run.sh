#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/podman-network.sh

podman rm -f cloudreve

mkdir -vp data/{uploads,avatar} \
&& touch data/conf.ini \
&& touch data/cloudreve.db


podman run -d \
    --name cloudreve \
    --network iuxt \
    --mount type=bind,source=./data/conf.ini,target=/cloudreve/conf.ini \
    --mount type=bind,source=./data/cloudreve.db,target=/cloudreve/cloudreve.db \
    -v $PWD/data/uploads:/cloudreve/uploads \
    -v $PWD/data/avatar:/cloudreve/avatar \
    -v $PWD/downloads:/downloads \
    --restart=always \
    cloudreve/cloudreve:latest

podman run -d \
    --name aria2 \
    --network iuxt \
    --restart unless-stopped \
    --log-opt max-size=1m \
    -e PUID=$UID \
    -e PGID=$(id -g) \
    -e UMASK_SET=022 \
    -e RPC_SECRET=com.012 \
    -e RPC_PORT=6800 \
    -e LISTEN_PORT=6888 \
    -v $PWD/aria2-config:/config \
    -v $PWD/downloads:/downloads \
    p3terx/aria2-pro



../public/add_config_to_nginx.sh
