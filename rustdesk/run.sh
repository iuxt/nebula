#!/bin/bash
cd $(dirname $0)

podman run -td --name hbbs \
    -v ./data:/root \
           --net=host \
    --restart unless-stopped \
    rustdesk/rustdesk-server hbbs -k _

podman run -td --name hbbr \
    -v ./data:/root \
           --net=host \
    --restart unless-stopped \
    rustdesk/rustdesk-server hbbr -k _

