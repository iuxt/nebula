#!/bin/bash

i=0
while true
do
  echo "第 ${i} 次尝试访问"
  i=$((i+1))
  curl -s "https://guanyu.example.com/xxx" -o /dev/null
done
