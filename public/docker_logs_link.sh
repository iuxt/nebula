#!/bin/bash
APP_NAME=$1

# 日志处理
LOG_PATH=$(docker inspect ${APP_NAME} | grep "LogPath" | awk -F '"' '{print $(NF-1)}')
mkdir -p /root/logs

set -euo pipefail
ln -sf ${LOG_PATH} /root/logs/${APP_NAME}.log

