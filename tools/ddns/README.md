# 调用云服务商api实现动态更新DNS

## 直接运行方式

这是个ddns的python实现，调用dnspod的api

首先准备配置文件

```bash
cp config.ini.example config.ini
```

生成虚拟环境

```bash
python -m venv venv
```

启用虚拟环境

```bash
source ./venv/bin/activate   # Linux 环境
venv\Scripts\activate.bat    # Windows 环境
```

crontab 示例：

```bash
*/10 * * * * cd /data/code/quickstart/ddns/ && ./venv/bin/python ./main.py >> /data/logs/cron.log 2>&1
```

## 使用Docker运行方式

```bash
docker run -d \
    --name ddns \
    --network=host \
    --restart unless-stopped \
    --log-opt max-size=1m \
    --mount type=bind,source=$(pwd)/config.ini,target=/root/config.ini \
    iuxt/ddns:latest
```
