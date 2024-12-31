#!/usr/bin/env python3
import time
import hmac
import hashlib
import base64
import urllib.parse
import configparser
import requests
import sys

now = str(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))

# 读取配置文件
conf = configparser.ConfigParser()
conf.read("config.ini")
secret = conf["dingtalk"]["secret"]
webhook_url = conf["dingtalk"]["webhook_url"]

# 根据时间戳生成签名
timestamp = str(round(time.time() * 1000))
secret_enc = secret.encode('utf-8')
string_to_sign = '{}\n{}'.format(timestamp, secret)
string_to_sign_enc = string_to_sign.encode('utf-8')
hmac_code = hmac.new(secret_enc, string_to_sign_enc, digestmod=hashlib.sha256).digest()
sign = urllib.parse.quote_plus(base64.b64encode(hmac_code))

# 要发送的数据
data = """
{
    "msgtype":"text",
    "text": {
        "content": "%s  %s"
    }
}
""" %(now, sys.argv[1])

# url参数
params={
    'timestamp': timestamp,
    'sign': sign
}

# header
header = {'Content-Type': 'application/json'}

# post消息出去
r = requests.post(webhook_url, headers=header, params=params, data=data.encode('utf-8'))
print(r.text)
