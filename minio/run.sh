#!/bin/bash
#

docker rm -f minio

docker run --name minio -d \
    --env-file=.env \
    --network iuxt \
    -v ./data:/data \
    -v ./config:/root/.mc \
    minio/minio:RELEASE.2025-04-22T22-12-26Z server --console-address ":9001" /data

../public/add_config_to_nginx.sh

sleep 2
docker logs minio

