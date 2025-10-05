## 启动服务


我的证书是自签名的 *.i.com 泛域名，假设我用 hub.i.com

## 绑定hosts

```
192.168.0.11   hub.i.com
```

## 修改docker配置

```bash
mkdir -p /etc/docker/certs.d/hub.i.com/
cp i.com.crt /etc/docker/certs.d/hub.i.com/
```