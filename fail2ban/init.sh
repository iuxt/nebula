#!/bin/bash

set -euo pipefail
cd $(dirname $0)

# 获取SSH日志路径
get_sshd_log_path() {
    if [ -f /var/log/auth.log ]; then
        echo "/var/log/auth.log"
    elif [ -f /var/log/secure ]; then
        echo "/var/log/secure"
    else
        echo "无法确定SSH日志路径！请手动检查。" >&2
        exit 1
    fi
}

# 获取SSH端口
get_sshd_port() {
    sshd_config="/etc/ssh/sshd_config"
    if [ -f "$sshd_config" ]; then
        port=$(grep -i "^Port" "$sshd_config" | awk '{print $2}' | head -n 1)
        if [ -n "$port" ]; then
            echo "$port"
        else
            echo "22"  # 默认SSH端口
        fi
    else
        echo "22"
    fi
}

# 生成fail2ban配置
generate_fail2ban_config() {
    log_path="$1"
    ssh_port="$2"
    config_file="./config/fail2ban/jail.d/sshd.conf"

    echo "生成fail2ban配置到: $config_file"
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

    echo "配置已生成。重启fail2ban生效:"
}

# 主流程
log_path=$(get_sshd_log_path)
sshd_port=$(get_sshd_port)

echo "检测到SSH日志路径: $log_path"
echo "检测到SSH端口: $sshd_port"

generate_fail2ban_config "$log_path" "$sshd_port"


docker exec -it fail2ban fail2ban-client reload
docker exec -it fail2ban fail2ban-client status sshd
