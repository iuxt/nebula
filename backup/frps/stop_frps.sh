#!/bin/bash
set -euo pipefail
cd $(dirname $0)

podman rm -f frps

rm -f /etc/fail2ban/jail.d/frps.conf

systemctl enable fail2ban
systemctl reload fail2ban

fail2ban-client status

