#!/bin/bash
cd $(dirname $0)


docker rm -f hbbs

docker run -td --name hbbs \
    -v ./data:/root \
    --net=host \
    --restart unless-stopped \
    rustdesk/rustdesk-server hbbs -k _

docker rm -f hbbr

docker run -td --name hbbr \
    -v ./data:/root \
    --net=host \
    --restart unless-stopped \
    rustdesk/rustdesk-server hbbr -k _

