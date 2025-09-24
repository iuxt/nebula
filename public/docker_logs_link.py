#!/usr/bin/env python3

from typing import Optional
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


def make_log_link(container_name: str, link_path: Optional[str] = None) -> str:
    """创建nginx日志文件的符号链接"""
    # 获取nginx容器的日志路径
    result = run_command(f"docker inspect {container_name} --format '{{{{.LogPath}}}}'")
    log_path = result.stdout.strip()
    if not log_path:
        print("无法获取nginx容器的日志路径。请确保nginx容器正在运行。")
        sys.exit(1)

    # 获取链接路径
    if link_path is None:
        link_path = os.path.join("/root/logs", f"{container_name}.log")
    os.makedirs(os.path.dirname(link_path), exist_ok=True)

    # 创建符号链接
    try:
        if os.path.islink(link_path) or os.path.exists(link_path):
            os.remove(link_path)
        os.symlink(log_path, link_path)
        print(f"已创建符号链接: {link_path} -> {log_path}")
    except Exception as e:
        print(f"创建符号链接失败: {e}")
        sys.exit(1)


if __name__ == "__main__":
    make_log_link(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)