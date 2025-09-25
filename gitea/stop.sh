#!/bin/bash
cd $(dirname $0)


docker rm -f gitea


../public/remove_config_from_nginx.py
../nginx/run.py
