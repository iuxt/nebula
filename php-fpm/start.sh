#!/bin/bash
cd $(dirname $0)

docker rm -f php-test
chown -R 33:33 ./app 
docker run --rm -d --name php-test \
	--network iuxt \
	-v ./php.ini:/usr/local/etc/php/conf.d/php.ini \
	-v ./extensions:/extensions \
	-v ./app:/var/www/html \
	-p 80:80 \
	iuxt/php:8.1.32-apache
