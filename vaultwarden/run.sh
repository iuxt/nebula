#!/bin/bash
cd $(dirname $0)

../public/docker-network.py

docker rm -f vaultwarden

docker run -d \
    -v "$(pwd)"/vaultwarden_data/:/data/ \
    --env-file="$(pwd)"/.env \
    --network iuxt \
    --name=vaultwarden \
    --restart=always \
    --log-driver=json-file \
    --log-opt max-size=1G \
    vaultwarden/server:1.33.2

# 生效nginx规则
../public/add_config_to_nginx.py

# 日志处理
../public/docker_logs_link.sh $(basename $(cd $(dirname $0) && pwd))


# fail2ban规则
cd fail2ban && ./set_fail2ban.sh

