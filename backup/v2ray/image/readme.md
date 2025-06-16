## 如何构建多平台镜像

```bash
docker buildx create --use --name buildx --node buildx --driver-opt network=host
docker run --privileged --rm tonistiigi/binfmt --install all

docker buildx build --push \
    --tag iuxt/v2ray:v5.29.3 \
    --platform linux/amd64,linux/arm64 .
```
