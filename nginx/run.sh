#!/bin/bash
set -uo pipefail
cd $(dirname $0)

../public/docker-network.sh

docker rm -f nginx

# stream.d里面的端口，需要进行转发
FORWARD_PORT=$(grep -h "listen" stream.d/*.conf | awk 'NF > 0 {print $NF}' | sed 's/;//')

# 初始化一个变量存储端口映射
PORT_MAPPING=""

# 遍历每个端口，拼接成 docker 的端口映射格式
for i in $FORWARD_PORT; do
    PORT_MAPPING="$PORT_MAPPING -p $i:$i"
done

# 输出最终的结果
echo $PORT_MAPPING


docker run -d --name nginx \
  -v ./www:/usr/share/nginx/html:ro \
  -v ./nginx.conf:/etc/nginx/nginx.conf \
  -v ./conf.d:/etc/nginx/conf.d \
  -v ./stream.d:/etc/nginx/stream.d \
  -v ./ssl:/etc/nginx/ssl \
  -v ./src:/src \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
  -p 80:80 \
  -p 443:443 \
  $PORT_MAPPING \
  --add-host=host.docker.internal:host-gateway \
  --network iuxt \
  --restart always \
  --log-driver=json-file \
  --log-opt max-size=1G \
  docker.io/nginx:1.27.0


# 日志处理
../public/docker_logs_link.sh $(basename $(cd $(dirname $0) && pwd))

cd fail2ban && sudo ./set_fail2ban.sh

