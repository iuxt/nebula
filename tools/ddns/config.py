import configparser
import os


# 获取config配置文件
def get_config(section, key):
    config = configparser.ConfigParser()
    # 其中 os.path.split(os.path.realpath(__file__))[0] 得到的是当前文件模块的目录
    path = os.path.join(os.path.dirname(__file__), 'config.ini')
    config.read(path, encoding='utf-8')
    return config.get(section, key)