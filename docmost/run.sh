#!/bin/bash

docker rm -f docmost

chown -R 1000:1000 data/

docker run -d --name docmost \
    --network iuxt \
    --restart unless-stopped \
    -v ./data:/app/data/storage \
	--env-file=.env \
    docmost/docmost:0.23.2


../public/add_config_to_nginx.py
