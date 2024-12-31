#!/bin/bash
set -euo pipefail
cd $(dirname $0)

source .env

../public/docker-network.sh

docker run --name mysql \
       -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
       -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
       -v "${MYSQL_DATA}":/var/lib/mysql \
       -v ./mysql-files:/var/lib/mysql-files \
       -v ./config:/etc/mysql/conf.d \
       -v ./init_sql:/docker-entrypoint-initdb.d \
       -p "${MYSQL_PORT}":3306 \
       -p "${MYSQLX_PORT}":33060 \
       --network iuxt \
       --restart "${RESTART}" \
       -d mysql:"${MYSQL_VERSION}"
