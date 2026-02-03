
测试fail2ban规则
```bash
docker exec -it fail2ban fail2ban-regex /root/logs/*.log /config/fail2ban/filter.d/nginx-http-cc.conf
```

