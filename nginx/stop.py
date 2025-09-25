#!/usr/bin/env python3


import os
import subprocess
import sys

def run_command(command, check=True, capture_output=True):
    """执行系统命令并返回结果"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=check,
            capture_output=capture_output,
            text=True
        )
        return result
    except subprocess.CalledProcessError as e:
        print(f"命令执行失败: {e}")
        print(f"错误输出: {e.stderr}")
        if check:
            sys.exit(1)
        return e


def main():
    # 切换到脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
    os.chdir(script_dir)
    print(f"切换到脚本目录: {script_dir}")


    # 移除已存在的nginx容器
    print("移除已存在的nginx容器（如果存在）...")
    run_command("docker rm -f nginx", check=False)
    
    print("移除nginx相关的fail2ban配置...")
    try:
        os.remove(os.path.join(script_dir, "fail2ban/jail.d/nginx-stream-cc.conf"))
    except FileNotFoundError:
        print("nginx-stream-cc.conf 文件不存在，跳过删除。")
    try:
        os.remove(os.path.join(script_dir, "fail2ban/jail.d/nginx-http-cc.conf"))
    except FileNotFoundError:
        print("nginx-http-cc.conf 文件不存在，跳过删除。")


    # 重启fail2ban服务
    print("重启fail2ban服务...")
    run_command("docker exec -it fail2ban fail2ban-client reload", check=False)
    run_command("docker exec -it fail2ban fail2ban-client status", check=False)


if __name__ == "__main__":
    main()