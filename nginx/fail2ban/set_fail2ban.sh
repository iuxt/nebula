#!/bin/bash
set -euo pipefail
cd $(dirname $0)


if [ "$(id -u)" != "0" ]; then
    echo "Error: 必须使用ROOT用户来运行， 你可以在命令前面加上 sudo "
    exit 1
fi

# 检查nginx日志文件
if [ ! -f /root/logs/nginx.log ]; then
    echo "Error: /root/logs/nginx.log 文件不存在，请先运行 nginx 启动脚本"
    exit 1
fi

# 检查fail2ban是否运行
if docker inspect fail2ban &>/dev/null; then
    echo "fail2ban 已经在运行了"
else
    echo 'fail2ban 没有运行'
    exit 1
fi

# nginx-http-cc
cp -f filter.d/nginx-http-cc.conf ../../fail2ban/config/fail2ban/filter.d/
cp -f jail.d/nginx-http-cc.conf ../../fail2ban/config/fail2ban/jail.d/

# nginx-stream-cc
cp -f filter.d/nginx-stream-cc.conf ../../fail2ban/config/fail2ban/filter.d/
cp -f jail.d/nginx-stream-cc.conf ../../fail2ban/config/fail2ban/jail.d/


docker exec -it fail2ban fail2ban-client reload

docker exec fail2ban fail2ban-client status nginx-http-cc
docker exec fail2ban fail2ban-client status nginx-stream-cc

