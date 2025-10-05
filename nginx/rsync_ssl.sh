#!/bin/bash

rsync -avz /root/nebula/nginx/ssl/ root@zhangfei.example.com:/root/nebula/nginx/ssl/
rsync -avz /root/nebula/nginx/ssl/ root@liubei.example.com:/root/nebula/nginx/ssl/

