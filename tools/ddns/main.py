import cloud_api.dnspod as dnspod
import cloud_api.namesilo as namesilo
import ipv6_addr
import config


real_value = ipv6_addr.getIPv6Address()

def dnspod_check():
    a = dnspod.DnsPodApi(id + "," + key, domain)

    if a.get_subdomain_info(sub_domain):
        if a.get_subdomain_info(sub_domain)[1] == real_value:
            print("记录已存在，值也是我需要的，不做修改")
        else:
            a.modify_record(sub_domain, a.get_subdomain_info(sub_domain)[0], real_value)
            print("修改现有的解析")
    else:
        a.create_record(sub_domain, real_value)
        print("增加新的解析")
    

def namesilo_check():
    a = namesilo.NamesiloApi(domain=domain, key=key)
    data = a.get_record(sub_domain)
    print(data)
    if data.get("value") == real_value:
        print("不用更新")
    else:
        print("调用更新方法")
        a.modify_record(record_id=data.get("record_id"), value=real_value)
    

if config.get_config("main", "cloud_api") == "dnspod":
    id = config.get_config("dnspod", "id")
    key = config.get_config("dnspod", "key")
    domain = config.get_config("dnspod", "domain")
    sub_domain = config.get_config("dnspod", "sub_domain")
    check_func = dnspod_check
elif config.get_config("main", "cloud_api") == "namesilo":
    key = config.get_config("namesilo", "key")
    domain = config.get_config("namesilo", "domain")
    sub_domain = config.get_config("namesilo", "sub_domain")
    check_func = namesilo_check


if __name__ == "__main__":
    check_func()
