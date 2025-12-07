## 说明

这个是使用一个域名来部署minio的方法
域名是： s3.example.com
控制台地址是： s3.example.com/ui/



```bash
docker run --name minio -d \
    --env-file=.env \
    --network iuxt \
    -v ./data:/data \
    -v ./config:/root/.mc \
    --restart always \
    minio/minio:RELEASE.2025-04-22T22-12-26Z server --console-address ":9001" /data
```


