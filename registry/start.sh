#!/bin/bash
cd $(dirname $0)

# 使用HTTP协议
# docker run -d \
#   --restart=always \
#   --name registry \
#   -v "$(pwd)"/data:/var/lib/registry \
#   -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
#   -p 5000:5000 \
#   registry:2


# 下面的是https的配置
docker run -d \
  --restart=always \
  --name registry \
  -v "$(pwd)"/certs:/certs \
  -v "$(pwd)"/data:/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/i.com.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/i.com.key \
  -p 443:443 \
  registry:2
