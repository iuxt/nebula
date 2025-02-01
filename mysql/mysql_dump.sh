#!/bin/bash
set -euo pipefail
cd $(dirname $0)

source ./.env
podman exec -it mysql bash -c "mysqldump -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD} --all-databases > /var/lib/mysql-files/all.sql"
