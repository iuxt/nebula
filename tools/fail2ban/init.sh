#!/bin/bash

set -euo pipefail
cd $(dirname $0)

cp system-fail2ban/jail.d/sshd.conf ../../fail2ban/config/fail2ban/jail.d/

docker exec -it fail2ban fail2ban-client reload
docker exec -it fail2ban fail2ban-client status sshd
