#!/bin/bash
cd $(dirname $0)

mkdir kafka-data
sudo chown -R 1001:1001 kafka-data

sudo docker network create ops

sudo docker run -d --name kafka-server --hostname kafka-server \
    --network ops \
    -e KAFKA_CFG_NODE_ID=0 \
    -e KAFKA_CFG_PROCESS_ROLES=controller,broker \
    -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
    -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
    -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka-server:9093 \
    -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER \
    -e KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true \
    -v ./kafka-data:/bitnami/kafka \
    -p 9092:9092 \
    -p 9093:9093 \
    bitnami/kafka:3.8.0
