#!/bin/bash

docker run -d --name postgres \
    -v ./data:/var/lib/postgresql/data \
    --network iuxt \
    --restart unless-stopped \
	--env-file=.env \
    postgres:16-alpine