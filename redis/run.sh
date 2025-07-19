#!/bin/bash

docker rm -f redis
docker run -d --name redis \
    --network iuxt \
    --restart unless-stopped \
    -v ./data:/data \
    redis:7.2-alpine
