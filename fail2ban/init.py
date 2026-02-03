#!/usr/bin/env python3
import os
import subprocess
import sys
from pathlib import Path

def get_ssh_log_path():
    """获取SSH日志文件路径"""
    log_paths = [
        "/var/log/auth.log",
        "/var/log/secure"
    ]
    
    for path in log_paths:
        if os.path.isfile(path):
            return path
    
    print("无法确定SSH日志路径！请手动检查。", file=sys.stderr)
    sys.exit(1)


def get_ssh_port():
    """获取SSH端口配置"""
    sshd_config = "/etc/ssh/sshd_config"
    
    if os.path.isfile(sshd_config):
        try:
            with open(sshd_config, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line.lower().startswith("port ") and not line.startswith("#"):
                        parts = line.split()
                        if len(parts) >= 2:
                            return parts[1]
        except (IOError, PermissionError) as e:
            print(f"读取SSH配置文件时出错: {e}", file=sys.stderr)
    
    return "22"  # 默认SSH端口


def generate_fail2ban_config(log_path, ssh_port):
    """生成fail2ban配置文件"""
    # 创建配置目录
    config_dir = Path("./config/fail2ban/jail.d")
    config_dir.mkdir(parents=True, exist_ok=True)
    
    config_file = config_dir / "sshd.local"
    
    config_content = f"""[sshd]
enabled = true
port = {ssh_port}
logpath = {log_path}
maxretry = 3
bantime = 1d
ignoreip = 127.0.0.1/8 ::1
mode   = aggressive
action = iptables-multiport[port="%(port)s", protocol="tcp", chain="INPUT"]
"""
    
    try:
        with open(config_file, 'w') as f:
            f.write(config_content)
        print(f"配置文件已生成: {config_file}")
        return True
    except (IOError, PermissionError) as e:
        print(f"写入配置文件时出错: {e}", file=sys.stderr)
        return False


def reload_fail2ban():
    """重新加载fail2ban配置并检查状态"""
    try:
        # 重新加载fail2ban
        subprocess.run([
            "docker", "exec", "-it", "fail2ban", 
            "fail2ban-client", "reload"
        ], check=True)
        
        print("fail2ban配置重新加载成功")
        
        # 检查sshd监狱状态
        subprocess.run([
            "docker", "exec", "-it", "fail2ban", 
            "fail2ban-client", "status", "sshd"
        ], check=True)
        
    except subprocess.CalledProcessError as e:
        print(f"执行docker命令时出错: {e}", file=sys.stderr)
        return False
    
    return True


def main():
    """主函数"""
    # 切换到脚本所在目录
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    # 获取SSH日志路径和端口
    log_path = get_ssh_log_path()
    ssh_port = get_ssh_port()
    
    print(f"检测到SSH日志路径: {log_path}")
    print(f"检测到SSH端口: {ssh_port}")
    
    # 生成fail2ban配置
    if generate_fail2ban_config(log_path, ssh_port):
        # 重新加载fail2ban
        reload_fail2ban()


if __name__ == "__main__":
    main()
