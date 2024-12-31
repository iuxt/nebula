#!/bin/bash

source .env

i=0
while true
do
  echo "第 ${i} 次尝试访问"
  i=$((i+1))
  curl "${check_http_url}"
done
