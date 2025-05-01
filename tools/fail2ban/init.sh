#!/bin/bash

# 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：本脚本需要以root权限运行！"
    exit 1
fi

# 检查系统是否为Ubuntu
if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ "$ID" = "ubuntu" ]; then
        echo "检测到Ubuntu系统"
    cp system-fail2ban/jail.d/ssh.conf /etc/fail2ban/jail.d/ssh.conf
    rm -f /etc/fail2ban/jail.d/defaults-debian.conf
    systemctl enable --now fail2ban
    systemctl reload fail2ban
        echo "操作完成。"
    else
        echo "当前系统不是Ubuntu，已跳过删除操作。"
    fi
else
    echo "无法检测系统类型：/etc/os-release 文件不存在。"
    exit 1
fi
