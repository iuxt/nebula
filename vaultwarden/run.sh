#!/bin/bash
cd $(dirname $0)

../public/docker-network.sh

docker rm -f vaultwarden

docker run -d \
    -v "$(pwd)"/vaultwarden_data/:/data/ \
    --env-file="$(pwd)"/.env \
    --network iuxt \
    --name=vaultwarden \
    --restart=always \
    --log-driver=json-file \
    --log-opt max-size=1G \
    docker.io/vaultwarden/server:latest

# 生效nginx规则
../public/add_config_to_nginx.sh

# 日志处理
../public/docker_logs_link.sh $(basename $(cd $(dirname $0) && pwd))


# fail2ban规则
cd fail2ban && ./set_fail2ban.sh
systemctl enable fail2ban
systemctl reload fail2ban

fail2ban-client status

