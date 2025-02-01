#!/bin/bash

podman exec nginx nginx -t

if [ $? -eq 0 ]; then
    podman exec nginx nginx -s reload
else
    echo "nginx配置文件不正确"
fi

