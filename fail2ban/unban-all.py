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


if __name__ == "__main__":
    run_command(["docker", "exec", "fail2ban", "fail2ban-client", "unban", "--all"])