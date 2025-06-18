#!/bin/bash

set -euo pipefail

cp system-fail2ban/jail.d/ssh.conf ../../fail2ban/config/jail.d/

docker exec -it fail2ban fail2ban-client reload
docker exec -it fail2ban fail2ban-client status sshd
