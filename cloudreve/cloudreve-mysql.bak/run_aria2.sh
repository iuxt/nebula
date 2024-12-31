#!/bin/bash

../public/docker-network.sh


docker run -d \
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
