#!/bin/sh

mkdir /app && cd /app || exit

if [ "$(uname -m)" = "x86_64" ]; then
    echo "x86"
    wget https://github.com/XTLS/Xray-core/releases/download/v25.3.6/Xray-linux-64.zip
    unzip Xray-linux-64.zip && rm -f $_
elif [ "$(uname -m)" = "aarch64" ]; then  
    echo "arm"
    wget https://github.com/XTLS/Xray-core/releases/download/v25.3.6/Xray-linux-arm64-v8a.zip
    unzip Xray-linux-arm64-v8a.zip && rm -f $_
fi
