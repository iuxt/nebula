#!/bin/sh

mkdir /v2ray && cd /v2ray || exit

if [ "$(uname -m)" = "x86_64" ]; then
    echo "x86"
    wget https://github.com/v2fly/v2ray-core/releases/download/v5.29.3/v2ray-linux-64.zip
    unzip v2ray-linux-64.zip && rm -f v2ray-linux-64.zip
elif [ "$(uname -m)" = "aarch64" ]; then  
    echo "arm"
    wget https://github.com/v2fly/v2ray-core/releases/download/v5.29.3/v2ray-linux-arm64-v8a.zip
    unzip v2ray-linux-arm64-v8a.zip && rm -f v2ray-linux-arm64-v8a.zip
fi
