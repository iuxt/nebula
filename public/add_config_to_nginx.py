#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

def main():
    # 当前目录名作为 app 名称
    app = os.path.basename(os.getcwd())
    print(app)

    # 路径
    custom_conf = "custom_nginx.conf"
    default_conf = "nginx.conf"
    target_conf = os.path.join("..", "nginx", "conf.d", f"{app}.conf")
    reload_script = os.path.join("..", "nginx", "reload.py")

    # 如果 custom_nginx.conf 不存在，就复制 nginx.conf
    if not os.path.exists(custom_conf):
        if not os.path.exists(default_conf):
            print(f"Error: {default_conf} not found.")
            sys.exit(1)
        shutil.copy(default_conf, custom_conf)

    # 强制复制 custom_nginx.conf 到目标文件
    shutil.copyfile(custom_conf, target_conf)
    print(f"Copied {custom_conf} → {target_conf}")

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

if __name__ == "__main__":
    main()
