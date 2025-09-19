#!/bin/bash

docker rm -f docmost

chown -R 1000:1000 data/

docker run -d --name docmost \
    --network iuxt \
    --restart unless-stopped \
    -v ./data:/app/data/storage \
    -e DATABASE_URL=postgresql://iuxt:vzVqG9ijCcco@postgres:5432/docmost?schema=public \
    -e REDIS_URL=redis://redis:6379 \
    -e APP_URL=https://doc.babudiu.com \
    -e APP_SECRET=6BrF0U3RR3G0DTfmXB92BZ6gHUhTnM4LFKHjCpbz \
    docmost/docmost:0.23.2


../public/add_config_to_nginx.sh
