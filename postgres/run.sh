#!/bin/bash

docker run -d --name postgres \
    -v ./data:/var/lib/postgresql/data \
    --network iuxt \
    --restart unless-stopped \
    -e POSTGRES_USER=iuxt \
    -e POSTGRES_PASSWORD=vzVqG9ijCcco \
    -e POSTGRES_DB=iuxt \
    postgres:16-alpine