#!/bin/bash

NODE_NAME=thinkbook

wg genkey | tee ${NODE_NAME}.key | wg pubkey > ${NODE_NAME}.pub
wg genpsk > ${NODE_NAME}_pre.key


echo "
[Interface]
  PrivateKey = $(cat ${NODE_NAME}.key)
  Address = 10.0.8.10/24
  DNS = 8.8.8.8

[Peer]
  PublicKey = $(cat ${NODE_NAME}.pub)
  PresharedKey = $(cat ${NODE_NAME}_pre.key)
  Endpoint = zhaoyun.babudiu.com:50814
  AllowedIPs = 10.0.8.0/24
  PersistentKeepalive = 25 " > ${NODE_NAME}.conf