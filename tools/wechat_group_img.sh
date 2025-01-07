#!/bin/bash
cd $(dirname $0)

if [ $(ls -al /root/*.jpeg | wc -l) -eq 1 ];then
  mv /root/*.jpeg ../nginx/src/card/wechat_ops_group.JPG 
fi

