#!/bin/bash
cd $(dirname $0)

docker exec nginx nginx -t

if [ $? -eq 0 ]; then
    docker exec nginx nginx -s reload
else
    echo "nginx配置文件不正确"
fi

