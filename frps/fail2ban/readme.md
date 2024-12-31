# fail2ban防止暴力破解配置

## 测试方法

```bash
echo "我的公网IP是："
curl 4.ipw.cn ; echo 

for i in {1..55}; do
    echo $i 次访问
    curl https://baidu.com
done
```