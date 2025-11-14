#!/bin/bash

docker rm -f redis
docker run -d --name redis \
    --network iuxt \
    --restart unless-stopped \
    -p 127.0.0.1:6379:6379 \
    --mount type=bind,source=./redis.conf,target=/app/redis.conf,readonly \
    -v ./data:/data \
    redis:7.2-alpine redis-server /app/redis.conf
