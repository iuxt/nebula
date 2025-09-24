#!/usr/bin/env python3
import subprocess

network_name = "iuxt"

def check_docker_network_exists(network_name):
    """检查Docker网络是否存在"""
    try:
        # 执行docker network ls命令并过滤指定网络
        result = subprocess.run(
            f"docker network ls --filter name=^{network_name}$ --format '{{.Name}}'",
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
        # 如果输出不为空，说明网络存在
        return result.stdout.strip() == network_name
    except subprocess.CalledProcessError:
        # 命令执行失败（通常是网络不存在）
        return False

# 使用示例
if check_docker_network_exists(network_name):
    print("网络存在")
else:
    print("网络不存在，创建docker网络...")
    try:
        # 执行docker network ls命令并过滤指定网络
        result = subprocess.run(
            f"docker network create {network_name}",
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
    except subprocess.CalledProcessError as e:
        print(e)
