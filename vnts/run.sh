#!/bin/bash

docker run --name vnts -d \
	-p 29872:29872/udp \
	--network iuxt \
	iuxt/vnts:1.12.2
