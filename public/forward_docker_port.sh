#!/bin/bash

CONTAINER_NAME_OR_ID="你的容器名或ID"
HOST_PORT=8080
CONTAINER_PORT=80

# 获取容器IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME_OR_ID)

echo "容器IP: $CONTAINER_IP"

# 添加iptables规则
echo "添加iptables规则..."
sudo iptables -t nat -A DOCKER -p tcp --dport $HOST_PORT -j DNAT --to-destination $CONTAINER_IP:$CONTAINER_PORT
sudo iptables -t filter -A DOCKER -p tcp -d $CONTAINER_IP --dport $CONTAINER_PORT -j ACCEPT

echo "端口映射添加完成：$HOST_PORT -> $CONTAINER_IP:$CONTAINER_PORT"
echo "使用以下命令测试：curl http://localhost:$HOST_PORT"
