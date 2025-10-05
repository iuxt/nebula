#!/bin/bash

source .env

i=0
while true
do
  echo "第 ${i} 次尝试访问"
  i=$((i+1))
  ssh root@"guanyu.example.com" -p 22 -i ./id_rsa
done
