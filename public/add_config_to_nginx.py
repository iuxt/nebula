#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys


def copy_nginx_conf(app, conf_type):
    if conf_type == "http":
        custom_conf = "custom_nginx.conf"
        default_conf = "nginx.conf"
        target_conf = os.path.join("..", "nginx", "conf.d", f"{app}.conf")
    elif conf_type == "stream":
        custom_conf = "custom_nginx-stream.conf"
        default_conf = "nginx-stream.conf"
        target_conf = os.path.join("..", "nginx", "stream.d", f"{app}.conf")
    else:
        raise ValueError("Invalid conf_type. Must be 'http' or 'stream'.")

    # 如果 custom_nginx.conf 不存在，就复制 nginx.conf
    if not os.path.exists(custom_conf):
        if not os.path.exists(default_conf):
            print(f"Error: {default_conf} not found.")
            sys.exit(1)
        shutil.copy(default_conf, custom_conf)

    # 强制复制 custom_nginx.conf 到目标文件
    shutil.copyfile(custom_conf, target_conf)
    print(f"Copied {custom_conf} → {target_conf}")


def reload_nginx():
    reload_script = os.path.join("..", "nginx", "reload.py")
    # 调用 reload.py
    if os.path.exists(reload_script):
        result = subprocess.run(
            [sys.executable, reload_script],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print("Reload success")
            print(result.stdout.strip())
        else:
            print("Reload failed:")
            print(result.stderr.strip())
            sys.exit(result.returncode)
    else:
        print(f"Error: {reload_script} not found.")
        sys.exit(1)

def restart_nginx():
    restart_script = os.path.join("..", "nginx", "run.py")
    # 调用 reload.py
    if os.path.exists(restart_script):
        result = subprocess.run(
            [sys.executable, restart_script],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print("Reload success")
            print(result.stdout.strip())
        else:
            print("Reload failed:")
            print(result.stderr.strip())
            sys.exit(result.returncode)
    else:
        print(f"Error: {restart_script} not found.")
        sys.exit(1)


def main():
    # 当前目录名作为 app 名称
    app = os.path.basename(os.getcwd())
    print(app)

    if os.path.exists("nginx.conf"):
        copy_nginx_conf(app, "http")
        restart_nginx()
    if os.path.exists("nginx-stream.conf"):
        copy_nginx_conf(app, "stream")
        restart_nginx()




if __name__ == "__main__":
    main()
