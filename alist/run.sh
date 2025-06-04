#!/bin/bash

docker rm -f alist
docker run -d --restart=unless-stopped \
    --network=iuxt \
    -v ./data:/data \
    --name="alist" \
    iuxt/alist:v3.45.0

../public/add_config_to_nginx.sh
