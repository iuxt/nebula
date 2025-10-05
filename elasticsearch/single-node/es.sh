#!/bin/bash

docker network create elasticsearch
docker rm -f elasticsearch kibana
mkdir es-data es-logs
sudo chown -R 1000 es-data es-logs


docker run -d --name elasticsearch \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -e "discovery.type=single-node" \
    -v "$(pwd)"/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro \
    -v "$(pwd)"/es-data:/usr/share/elasticsearch/data:rw \
    -v "$(pwd)"/es-logs:/usr/share/elasticsearch/logs:rw \
    --privileged --network elasticsearch \
    -p 9200:9200 -p 9300:9300 \
    elasticsearch:7.17.14


# 等待服务启动正常
sleep 10
while true
do
  docker exec elasticsearch bash -c "curl -s -o /dev/null http://localhost:9200"
  if [ $? == 0 ];then
    break
  fi
  echo "waiting..."
  sleep 1
done

# 初始化ES密码
ELASTIC_PASSWORD="ywphQxkiLOO0aSPjmvND"
echo "y
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}
${ELASTIC_PASSWORD}" | docker exec -i elasticsearch /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive



# 启动kibana
docker run -d --name kibana \
    --net elasticsearch \
    -p 5601:5601 \
    -v "$(pwd)"/kibana.yml:/usr/share/kibana/config/kibana.yml \
    kibana:7.17.14
