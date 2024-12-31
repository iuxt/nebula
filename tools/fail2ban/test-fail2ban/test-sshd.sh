#!/bin/bash

source .env

i=0
while true
do
  echo "第 ${i} 次尝试访问"
  i=$((i+1))
  ssh root@"${check_sshd_host}" -p 2222 -i ./id_rsa
done
