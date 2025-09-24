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

def get_jail_list():
    """获取fail2ban所有监狱列表"""
    try:
        result = subprocess.run(
            ["docker", "exec", "fail2ban", "fail2ban-client", "status"],
            check=True,
            text=True,
            capture_output=True
        )
        # 打印原始输出，用于调试
        # print("原始输出:", result.stdout)
        
        # 正确解析监狱列表
        lines = result.stdout.strip().split('\n')
        
        # 查找包含Jail list的行
        jail_list_line = None
        for line in lines:
            if 'Jail list:' in line:
                jail_list_line = line
                break
        
        if jail_list_line:
            # 提取监狱名称列表
            jail_list = jail_list_line.split('Jail list:')[-1].strip().split(', ')
            # 处理可能的空格和空字符串
            return [jail.strip() for jail in jail_list if jail.strip()]
        else:
            # 如果找不到Jail list行，尝试其他可能的格式
            # 检查最后一行是否包含监狱列表
            if lines and len(lines) > 1:
                last_line = lines[-1]
                if ':' in last_line:
                    jail_list = last_line.split(':')[-1].strip().split(', ')
                    return [jail.strip() for jail in jail_list if jail.strip()]
        
        # 如果没有找到监狱列表，返回空列表
        print("未找到监狱列表", file=sys.stderr)
        return []
        
    except subprocess.CalledProcessError as e:
        print(f"获取fail2ban监狱列表失败: {e}", file=sys.stderr)
        sys.exit(e.returncode)

def main():
    """主函数"""
    jail_list = get_jail_list()
    print("监狱列表:", jail_list)
    for jail in jail_list:
        run_command(["docker", "exec", "fail2ban", "fail2ban-client", "status", jail])


if __name__ == "__main__":
    main()