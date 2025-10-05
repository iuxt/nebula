#!/bin/bash

# 设置Elasticsearch版本
ELASTIC_VERSION=7.17.14

sudo sysctl -w vm.max_map_count=262144

docker network create --subnet=172.16.0.0/24 elasticsearch-br0
mkdir es-data1 es-logs1
mkdir es-data2 es-logs2
mkdir es-data3 es-logs3
mkdir certs
sudo chown -R 1000 es-data1 es-logs1
sudo chown -R 1000 es-data2 es-logs2
sudo chown -R 1000 es-data3 es-logs3
sudo chown -R 1000 certs


# 生成证书
docker run --rm -it -v $(pwd)/certs:/tmp/certs elasticsearch:${ELASTIC_VERSION} bash -c \
    'echo -e "\n\n" | /usr/share/elasticsearch/bin/elasticsearch-certutil ca -s -days 36500 && \
    echo -e "\n\n\n" | /usr/share/elasticsearch/bin/elasticsearch-certutil cert -s -days 36500 --ca elastic-stack-ca.p12 && \
    mv /usr/share/elasticsearch/*.p12 /tmp/certs && \
    chmod 644 /tmp/certs/*'


docker run -d --name elasticsearch1 \
    --ulimit memlock=-1:-1 \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -e node.name=elasticsearch1 \
    -e cluster.name=es-cluster \
    -e discovery.seed_hosts=elasticsearch2,elasticsearch3 \
    -e cluster.initial_master_nodes=elasticsearch1,elasticsearch2,elasticsearch3 \
    -e bootstrap.memory_lock=true \
    -e xpack.security.enabled=true \
    -e http.cors.enabled=true \
    -e http.cors.allow-origin="*" \
    -e http.cors.allow-headers=Authorization \
    -e xpack.security.enabled=true \
    -e xpack.security.transport.ssl.enabled=true \
    -e xpack.security.transport.ssl.verification_mode=certificate \
    -e xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    -e xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    -v ./es-data1:/usr/share/elasticsearch/data:rw \
    -v ./es-logs1:/usr/share/elasticsearch/logs:rw \
    --mount type=bind,source=$(pwd)/certs/elastic-certificates.p12,target=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    --network elasticsearch-br0 \
    --ip 172.16.0.11 \
    -p 9201:9200 -p 9301:9300 \
    elasticsearch:${ELASTIC_VERSION}

docker run -d --name elasticsearch2 \
    --ulimit memlock=-1:-1 \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -e node.name=elasticsearch2 \
    -e cluster.name=es-cluster \
    -e discovery.seed_hosts=elasticsearch1,elasticsearch3 \
    -e cluster.initial_master_nodes=elasticsearch1,elasticsearch2,elasticsearch3 \
    -e bootstrap.memory_lock=true \
    -e xpack.security.enabled=true \
    -e http.cors.enabled=true \
    -e http.cors.allow-origin="*" \
    -e http.cors.allow-headers=Authorization \
    -e xpack.security.enabled=true \
    -e xpack.security.transport.ssl.enabled=true \
    -e xpack.security.transport.ssl.verification_mode=certificate \
    -e xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    -e xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    -v ./es-data2:/usr/share/elasticsearch/data:rw \
    -v ./es-logs2:/usr/share/elasticsearch/logs:rw \
    --mount type=bind,source=$(pwd)/certs/elastic-certificates.p12,target=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    --network elasticsearch-br0 \
    --ip 172.16.0.12 \
    -p 9202:9200 -p 9302:9300 \
    elasticsearch:${ELASTIC_VERSION}

docker run -d --name elasticsearch3 \
    --ulimit memlock=-1:-1 \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -e node.name=elasticsearch3 \
    -e cluster.name=es-cluster \
    -e discovery.seed_hosts=elasticsearch1,elasticsearch2 \
    -e cluster.initial_master_nodes=elasticsearch1,elasticsearch2,elasticsearch3 \
    -e bootstrap.memory_lock=true \
    -e xpack.security.enabled=true \
    -e http.cors.enabled=true \
    -e http.cors.allow-origin="*" \
    -e http.cors.allow-headers=Authorization \
    -e xpack.security.enabled=true \
    -e xpack.security.transport.ssl.enabled=true \
    -e xpack.security.transport.ssl.verification_mode=certificate \
    -e xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    -e xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    -v ./es-data3:/usr/share/elasticsearch/data:rw \
    -v ./es-logs3:/usr/share/elasticsearch/logs:rw \
    --mount type=bind,source=$(pwd)/certs/elastic-certificates.p12,target=/usr/share/elasticsearch/config/elastic-certificates.p12 \
    --network elasticsearch-br0 \
    --ip 172.16.0.13 \
    -p 9203:9200 -p 9303:9300 \
    elasticsearch:${ELASTIC_VERSION}


# 等待服务启动正常
sleep 10
while true
do
  docker exec elasticsearch1 bash -c "curl -s -o /dev/null http://localhost:9200"
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
${ELASTIC_PASSWORD}" | docker exec -i elasticsearch1 /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive



# 启动kibana
docker run -d --name kibana \
    --net elasticsearch-br0 \
    -p 5601:5601 \
    -v "$(pwd)"/kibana.yml:/usr/share/kibana/config/kibana.yml \
    kibana:${ELASTIC_VERSION}
