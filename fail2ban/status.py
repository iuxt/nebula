#!/usr/bin/env python3
import subprocess
import sys

def run_command(command):
    """执行shell命令并处理错误"""
    try:
        subprocess.run(command, check=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"执行命令失败: {e}", file=sys.stderr)
        sys.exit(e.returncode)

def get_jail_list():
    """获取fail2ban所有监狱列表"""
    try:
        result = subprocess.run(
            ["docker", "exec", "fail2ban", "fail2ban-client", "status"],
            check=True,
            text=True,
            capture_output=True
        )
        jail_list = result.stdout.splitlines()[0].split(":")[-1].split(",")
        return [jail.strip() for jail in jail_list]
    except subprocess.CalledProcessError as e:
        print(f"获取fail2ban监狱列表失败: {e}", file=sys.stderr)
        sys.exit(e.returncode)

def main():
    """主函数"""
    jail_list = get_jail_list()
    for jail in jail_list:
        run_command(["docker", "exec", "fail2ban", "fail2ban-client", "status", jail])