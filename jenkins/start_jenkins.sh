#!/bin/bash
cd $(dirname $0)

docker run -d \
    -v jenkins_home:/var/jenkins_home \
    -p 8080:8080 -p 50000:50000 \
    --name jenkins \
    --restart=on-failure \
    jenkins/jenkins:lts-jdk11

../public/add_config_to_nginx.sh