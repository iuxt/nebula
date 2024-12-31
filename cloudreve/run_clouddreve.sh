#!/bin/bash
set -euo pipefail
cd $(dirname $0)

../public/docker-network.sh

docker rm -f cloudreve

mkdir -vp data/{uploads,avatar} \
&& touch data/conf.ini \
&& touch data/cloudreve.db


docker run -d \
    --name cloudreve \
    --network iuxt \
    --mount type=bind,source=./data/conf.ini,target=/cloudreve/conf.ini \
    --mount type=bind,source=./data/cloudreve.db,target=/cloudreve/cloudreve.db \
    -v $PWD/data/uploads:/cloudreve/uploads \
    -v $PWD/data/avatar:/cloudreve/avatar \
    -v $PWD/downloads:/downloads \
    --restart=always \
    cloudreve/cloudreve:latest

../public/add_config_to_nginx.sh
