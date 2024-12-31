import requests
import json



class DnsPodApi:
    def __init__(self, token, domain) -> None:
        self.token = token
        self.domain = domain

    def get_record_info(self):
        """
        获取记录详情
        """
        data = {
            "login_token": self.token,
            "format": "json",
            "domain": self.domain
        }
        r = requests.post("https://dnsapi.cn/Record.List", data=data)
        if r.status_code == 200:
            return r.json()["records"]
        else:
            print(r.json())

    def create_record(self, sub_domain, value):
        """
        创建记录
        """
        data = {
            "login_token" : self.token,
            "format": "json",
            "domain": self.domain,
            "sub_domain": sub_domain,
            "record_type": "AAAA",
            "record_line": "默认",
            "value": value
        }
        r = requests.post("https://dnsapi.cn/Record.Create", data=data)
        print(r.json())

    def get_subdomain_info(self, sub_domain):
        for i in self.get_record_info():
            if i["name"] == sub_domain:
                return [i["id"], i["value"]]
        return None
    
    def modify_record(self, sub_domain, record_id, value):
        data = {
            "login_token" : self.token,
            "format": "json",
            "domain": self.domain,
            "sub_domain": sub_domain,
            "record_id": record_id,
            "record_type": "AAAA",
            "record_line": "默认",
            "value": value
        }
        r = requests.post("https://dnsapi.cn/Record.Modify", data=data)
        print(r.json())


if __name__ == "__main__":
    id = "345512"
    key = "example_key"
    domain = "babudiu.com"
    sub_domain = "t-box"
    value = "1.1.1.1"
    
    a = DnsPodApi(id + "," + key, domain)
    
    if a.get_subdomain_info(sub_domain):
        if a.get_subdomain_info(sub_domain)[1] == value:
            print("记录已存在，值也是我需要的，不做修改")
        else:
            a.modify_record(sub_domain, a.get_subdomain_info(sub_domain)[0], value)
            print("修改现有的解析")
    else:
        a.create_record(sub_domain, value)
        print("增加新的解析")
