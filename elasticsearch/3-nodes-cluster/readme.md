## 证书生成

```bash
/usr/share/elasticsearch/bin/elasticsearch-certutil ca
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
```

## 初始化密码

```bash
docker exec elasticsearch1 bash -c "echo y | /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto"
```

## 重新设置密码

```bash
curl -XPUT -u elastic:belu3EfkGVLiU2vEcRno http://localhost:9200/_xpack/security/user/elastic/_password -H "Content-Type: application/json" -d '
{
  "password": "Ds8meuPwMDEv32f6qLdw"
}'
```

## 清理集群

```bash
docker rm -f kibana elasticsearch1 elasticsearch2 elasticsearch3
docker volume rm es-logs3  es-logs2  es-logs1  es-data3  es-data2  es-data1
```