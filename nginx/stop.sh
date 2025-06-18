#!/bin/bash
cd $(dirname $0)

docker rm -f nginx

sudo rm -f ../../fail2ban/config/fail2ban/jail.d/nginx-stream-cc.conf
sudo rm -f ../../fail2ban/config/fail2ban/jail.d/nginx-http-cc.conf

docker exec -it fail2ban fail2ban-client reload
docker exec -it fail2ban fail2ban-client status
