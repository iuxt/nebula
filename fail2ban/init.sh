#!/bin/bash
cd $(dirname $0)

# 获取SSH日志路径
if [ -f /var/log/auth.log ]; then
    log_path="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
    log_path="/var/log/secure"
else
    echo "无法确定SSH日志路径！请手动检查。" >&2
    exit 1
fi

# 获取SSH端口
sshd_config="/etc/ssh/sshd_config"
if [ -f "$sshd_config" ]; then
    port=$(grep -i "^Port" "$sshd_config" | awk '{print $2}' | head -n 1)
    if [ -n "$port" ]; then
        ssh_port="$port"
    else
        ssh_port="22"  # 默认SSH端口
    fi
else
    ssh_port="22"
fi

echo "检测到SSH日志路径: $log_path"
echo "检测到SSH端口: $ssh_port"

# 生成fail2ban配置
config_file="./config/fail2ban/jail.d/sshd.conf"
cat << EOF | sudo tee "$config_file" >/dev/null
[sshd]
enabled = true
port = $ssh_port
logpath = $log_path
maxretry = 3
bantime = 1d
ignoreip = 127.0.0.1/8 ::1
mode   = aggressive

EOF


docker exec -it fail2ban fail2ban-client reload
docker exec -it fail2ban fail2ban-client status sshd
