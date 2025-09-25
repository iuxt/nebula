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


def check_stream_port():
    """
    检查stream端口配置
    return: List[int] 端口列表
    """
    stream_conf_dir = "./stream.d"
    if not os.path.exists(stream_conf_dir):
        print(f"stream配置目录不存在: {stream_conf_dir}")
        return

    port_list = []
    for filename in os.listdir(stream_conf_dir):
        if filename.endswith(".conf"):
            filepath = os.path.join(stream_conf_dir, filename)
            with open(filepath, 'r') as file:
                for line in file:
                    line = line.strip()
                    if line.startswith("listen"):
                        parts = line.split()
                        if len(parts) >= 2:
                            port_part = parts[1]
                            port = port_part.split()[0].rstrip(';')
                            if port.isdigit():
                                port_num = int(port)
                                if port_num < 1 or port_num > 65535:
                                    print(f"错误: {filepath} 中的端口号 {port_num} 无效。必须在1-65535之间。")
                                    sys.exit(1)
                                else:
                                    if port_num in port_list:
                                        print(f"错误: 端口号 {port_num} 在多个配置文件中重复使用。")
                                        sys.exit(1)
                                    port_list.append(port_num)
                            else:
                                print(f"错误: {filepath} 中的端口号 {port} 不是有效的数字。")
                                sys.exit(1)
    return port_list


def get_docker_run_command() -> str:
    port_forward_commands = ""
    for port in check_stream_port():
        print(f"检测到stream端口: {port}")
        port_forward_commands += f"-p {port}:{port} "
    print(f"生成的端口转发命令: {port_forward_commands}")

    """生成docker run命令"""
    command = (
        "docker run -d --name nginx "
        "-v ./www:/usr/share/nginx/html:ro "
        "-v ./nginx.conf:/etc/nginx/nginx.conf "
        "-v ./conf.d:/etc/nginx/conf.d "
        "-v ./stream.d:/etc/nginx/stream.d "
        "-v ./ssl:/etc/nginx/ssl "
        "-v ./src:/src "
        "--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly "
        "-p 80:80 "
        "-p 443:443 "
        f"{port_forward_commands}"
        "--add-host=host.docker.internal:host-gateway "
        "--network iuxt "
        "--restart always "
        "--log-driver=json-file "
        "--log-opt max-size=1G "
        "docker.io/nginx:1.27.5"
    )
    return command


def main():
    # 切换到脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
    os.chdir(script_dir)
    print(f"切换到脚本目录: {script_dir}")

    # 确保docker网络存在
    run_command("../public/docker-network.py")

    # 移除已存在的nginx容器
    print("移除已存在的nginx容器（如果存在）...")
    run_command("docker rm -f nginx", check=False)

    # 启动新的nginx容器
    print("启动新的nginx容器...")
    run_command(get_docker_run_command())

    # 创建日志符号链接
    print("创建nginx日志符号链接...")
    public_dir = os.path.join(script_dir, "../public")
    docker_logs_link_script = os.path.join(public_dir, "docker_logs_link.py")
    if os.path.exists(docker_logs_link_script):
        run_command(f"python3 {docker_logs_link_script} nginx")
    else:
        print(f"错误: 找不到脚本 {docker_logs_link_script}")
        sys.exit(1)


    # 执行fail2ban设置脚本
    print("配置fail2ban...")
    fail2ban_dir = os.path.join(script_dir, "fail2ban")
    if os.path.exists(fail2ban_dir) and os.path.isdir(fail2ban_dir):
        os.chdir(fail2ban_dir)
        run_command("sudo ./set_fail2ban.sh")
        os.chdir(script_dir)
    else:
        print(f"警告: fail2ban目录不存在 - {fail2ban_dir}")
        print("跳过fail2ban配置")

    print("Nginx容器启动完成")


if __name__ == "__main__":
    main()
