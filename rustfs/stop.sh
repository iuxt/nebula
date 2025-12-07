#!/bin/bash
cd $(dirname $0)

docker rm -f rustfs


../public/remove_config_from_nginx.py
