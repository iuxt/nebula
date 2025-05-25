#!/bin/bash
docker-php-ext-configure mysqli
docker-php-ext-install mysqli
docker-php-ext-enable mysqli

# gd 模块
apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

# zip 模块
apt-get install -y libzip-dev
docker-php-ext-configure zip
docker-php-ext-install zip
docker-php-ext-enable zip

# exif 模块
docker-php-ext-configure exif
docker-php-ext-install exif
docker-php-ext-enable exif

# intl 模块
apt-get install -y libicu-dev
docker-php-ext-configure intl
docker-php-ext-install intl 
docker-php-ext-enable intl

# imagick 模块
apt-get install -y libmagickwand-dev
pecl install imagick
docker-php-ext-enable imagick

# opcache 模块
docker-php-ext-configure opcache --enable-opcache
docker-php-ext-install opcache
docker-php-ext-enable opcache


php -m