# 钉钉通知脚本

> 需要添加钉钉机器人，安全选择加签模式

## before use

1. install python
2. install requests

    ```bash
    pip install requests
    ```

3. copy config.ini.example to config.ini

    ```bash
    cp config.ini.example config.ini
    ```

4. change config.ini

## how to use

```bash
python3 dingtalk.py <content you want to send>
```

## crontab

```bash
0 */6 * * * cd /data/code/quickstart/dingtalk_notify/ && ./send_ipv6.sh >> /data/logs/dingtalk_notify.log 2>&1
```
