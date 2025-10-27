#!/usr/bin/env python3
import os
import subprocess
import sys

def main():
    # 当前目录名作为 app 名称
    app = os.path.basename(os.getcwd())
    print(app)
    target_conf = os.path.join("..", "nginx", "conf.d", f"{app}.conf")
    stream_conf = os.path.join("..", "nginx", "stream.d", f"{app}.conf")
    reload_script = os.path.join("..", "nginx", "reload.py")


    # 使用 os.remove() 删除文件，并处理文件不存在的情况
    try:
        if os.path.exists(target_conf):
            os.remove(target_conf)
            print(f"删除文件 {target_conf}")
        else:
            print(f"文件不存在: {target_conf}")
    except Exception as e:
        print(f"删除文件失败 {target_conf}: {e}")

    try:
        if os.path.exists(stream_conf):
            os.remove(stream_conf)
            print(f"删除文件 {stream_conf}")
        else:
            print(f"文件不存在: {stream_conf}")
    except Exception as e:
        print(f"删除文件失败 {stream_conf}: {e}")



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
