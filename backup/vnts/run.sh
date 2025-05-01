#!/bin/bash

docker rm -f vnts

docker run --name vnts -d \
    -p 29870:29870 \
    -p 29872:29872/udp \
    --network iuxt \
    --env-file=.env \
    registry.cn-hangzhou.aliyuncs.com/iuxt/vnts:1.2.12
