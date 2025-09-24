#!/usr/bin/env python3
import os
import subprocess
import sys

os.chdir(os.path.dirname(os.path.abspath(__file__)))

# 检查nginx配置
check = subprocess.run(['docker', 'exec', 'nginx', 'nginx', '-t'])

if check.returncode == 0:
    subprocess.run(['docker', 'exec', 'nginx', 'nginx', '-s', 'reload'])
else:
    print("nginx配置文件不正确")
    sys.exit(1)
