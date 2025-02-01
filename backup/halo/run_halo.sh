#!/bin/bash
cd $(dirname $0)

set -euo pipefail

../public/podman-network.sh

podman run -it -d --name halo \
  -v "$PWD"/halo_data:/root/.halo \
  --network iuxt \
  --restart always \
  halohub/halo:1.6.1

../public/add_config_to_nginx.sh
