#!/bin/bash
docker rm -f php-test
chown -R www-data:www-data ./app 
docker run --rm -d --name php-test \
	--network iuxt \
	-v ./php.ini:/usr/local/etc/php/conf.d/php.ini \
	-v ./extensions:/extensions \
	-v ./app:/var/www/html \
	-p 8080:80 \
iuxt/php:8.1.32-apache
