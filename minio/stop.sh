#!/bin/bash
cd $(dirname $0)

docker rm -f minio


../public/remove_config_from_nginx.py
