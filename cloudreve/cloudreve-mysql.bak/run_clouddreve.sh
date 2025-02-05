#!/bin/bash
set -euo pipefail

../public/docker-network.sh

docker rm -f cloudreve

docker run -d \
    --name cloudreve \
    --network iuxt \
    --mount type=bind,source=$PWD/conf.ini,target=/cloudreve/conf.ini \
    -v $PWD/data/uploads:/cloudreve/uploads \
    -v $PWD/data/avatar:/cloudreve/avatar \
    -v $PWD/downloads:/downloads \
    --restart=always \
    cloudreve/cloudreve:latest

../public/add_config_to_nginx.sh
