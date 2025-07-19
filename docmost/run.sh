#!/bin/bash

docker run -d --name docmost \
    --network iuxt \
    --restart unless-stopped \
    -v ./data:/app/data/storage \
    -e DATABASE_URL=postgresql://iuxt:vzVqG9ijCcco@postgres:5432/docmost?schema=public \
    -e REDIS_URL=redis://redis:6379 \
    -e APP_URL=https://doc.babudiu.com \
    -e APP_SECRET=Bs29GR1Hix7k \
    docmost/docmost:latest


../public/add_config_to_nginx.sh
