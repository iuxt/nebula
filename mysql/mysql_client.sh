#!/bin/bash
set -euo pipefail
cd $(dirname $0)

source ./.env
docker exec -it mysql bash -c "mysql -hlocalhost -uroot -p${MYSQL_ROOT_PASSWORD}"