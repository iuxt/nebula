#!/usr/bin/env python3
import subprocess
import sys


def reload_fail2ban():
    """重新加载fail2ban配置并检查状态"""
    try:
        subprocess.run([
            "docker", "exec", "-it", "fail2ban", 
            "fail2ban-client", "reload"
        ], check=True)
        
        print("fail2ban配置重新加载成功")

    except subprocess.CalledProcessError as e:
        print(f"执行docker命令时出错: {e}", file=sys.stderr)
        return False
    
    return True


if __name__ == "__main__":
    reload_fail2ban()