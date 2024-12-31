from dotenv import load_dotenv
import requests
import time
import os
import json
import sys
import hashlib
import base64
import hmac


class FeishuNotify():


    def __init__(self):
        # 加载.env 文件中的环境变量
        load_dotenv() 

        # 获取环境变量的值
        self.url = os.getenv("url") 
        self.sign_key = os.getenv("sign_key") 
        self.timestamp = str(round(time.time()))



    def gen_sign(self):
        # 拼接timestamp和secret
        string_to_sign = '{}\n{}'.format(self.timestamp, self.sign_key)
        hmac_code = hmac.new(string_to_sign.encode("utf-8"), digestmod=hashlib.sha256).digest()

        # 对结果进行base64处理
        sign = base64.b64encode(hmac_code).decode('utf-8')

        return sign


    def send_notify(self, title, content):
        self.title = title
        self.content = content
        
        data = {
            "timestamp": self.timestamp,
            "sign": self.gen_sign(),
            "msg_type": "interactive",
            "card": {
                "elements": [{
                        "tag": "div",
                        "text": {
                                "content": self.content,
                                "tag": "lark_md"
                        }
                }, {
                        "actions": [{
                                "tag": "button",
                                "text": {
                                        "content": "更多景点介绍 :玫瑰:",
                                        "tag": "lark_md"
                                },
                                "url": "https://www.example.com",
                                "type": "default",
                                "value": {}
                        }],
                        "tag": "action"
                }],
                "header": {
                        "title": {
                                "content": self.title,
                                "tag": "plain_text"
                        }
                }
            }
        }


        header = {'Content-Type': 'application/json'}

        r = requests.post(url=self.url, headers=header, data=json.dumps(data))
        print(r.text)



if __name__ == "__main__":
    a = FeishuNotify()
    a.send_notify(title=sys.argv[1], content=sys.argv[2])



'''
# 可以在Python中调用
import notify
a = notify.FeishuNotify()
a.send_notify(title='通知', content='hello')

# 也可以在命令行传参
python3 notify.py 通知 哈哈哈
'''
