#!/bin/bash
set -euo pipefail
cd $(dirname $0)

docker run \
  --name ipsec-vpn-server \
  --restart=always \
  -v "$(pwd)"/ikev2-vpn-data:/etc/ipsec.d \
  --env-file=.env \
  -p 500:500/udp \
  -p 4500:4500/udp \
  -d --privileged \
  --restart=always \
  hwdsl2/ipsec-vpn-server
