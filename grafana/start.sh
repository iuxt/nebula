#!/bin/bash
cd "$(dirname $0)" || exit

docker rm -f grafana
mkdir data
sudo chown -R 472:472 data
docker run -d --name=grafana \
    --restart always \
    --user 472 \
    -p 8000:3000 \
    --volume "./data:/var/lib/grafana" \
    --add-host=host.docker.internal:host-gateway \
    grafana/grafana

docker logs -f grafana
