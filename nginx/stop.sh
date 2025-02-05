#!/bin/bash

docker rm -f nginx

sudo rm -f /etc/fail2ban/jail.d/nginx-stream-cc.conf
sudo rm -f /etc/fail2ban/jail.d/nginx-http-cc.conf

sudo systemctl enable fail2ban
sudo systemctl reload fail2ban

sudo fail2ban-client status

