#!/usr/bin/env python3
import os
import subprocess
import sys

def run_command(command):
    """执行shell命令并处理错误"""
    try:
        print(f"执行命令: {' '.join(command)}")
        subprocess.run(command, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"命令执行失败: {e}", file=sys.stderr)
        return False


def main():
    # 切换到脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    print(f"当前目录: {os.getcwd()}")
    
    # 删除已存在的fail2ban容器
    print("正在删除已存在的fail2ban容器...")
    # 忽略删除失败的情况，因为容器可能不存在
    subprocess.run(["docker", "rm", "-f", "fail2ban"], check=False)
    
    # 运行新的fail2ban容器
    print("正在启动新的fail2ban容器...")
    docker_run_command = [
        "docker", "run", "-d",
        "--name=fail2ban",
        "--net=host",
        "--cap-add=NET_ADMIN",
        "--cap-add=NET_RAW",
        "-e", "PUID=1000",
        "-e", "PGID=1000",
        "-e", "TZ=Etc/UTC",
        "-e", "VERBOSITY=-vv",
        "-v", f"{script_dir}/config:/config",
        "-v", "/var/log:/var/log:ro",
        "-v", "/root/logs:/root/logs:ro",
        "-v", "/var/lib/docker/containers:/var/lib/docker/containers:ro",
        "--restart", "unless-stopped",
        "lscr.io/linuxserver/fail2ban:latest"
    ]
    
    if run_command(docker_run_command):
        print("fail2ban容器启动成功!")
        sys.exit(0)
    else:
        print("fail2ban容器启动失败!")
        sys.exit(1)

if __name__ == "__main__":
    main()
    
