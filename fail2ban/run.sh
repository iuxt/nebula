#!/bin/bash
cd $(dirname $0)

docker rm -f fail2ban

docker run -d \
  --name=fail2ban \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e VERBOSITY=-vv \
  -v ./config:/config \
  -v /var/log:/var/log:ro \
  -v /root/logs:/root/logs:ro \
  -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
  --restart unless-stopped \
  lscr.io/linuxserver/fail2ban:latest
