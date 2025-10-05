FROM php:8.1.32-apache
RUN docker-php-ext-configure mysqli && \
    docker-php-ext-install mysqli && \
    docker-php-ext-enable mysqli

RUN apt-get update && apt-get install -y \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev && \
	docker-php-ext-configure gd --with-freetype --with-jpeg && \
	docker-php-ext-install -j$(nproc) gd

RUN apt-get install -y libzip-dev && \
    docker-php-ext-configure zip && \
    docker-php-ext-install zip && \
    docker-php-ext-enable zip && \
    apt-get clean all

RUN docker-php-ext-configure exif && \
    docker-php-ext-install exif && \
    docker-php-ext-enable exif

RUN apt-get install -y libicu-dev && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    docker-php-ext-enable intl && \
    apt-get clean all

RUN apt-get install -y libmagickwand-dev && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    apt-get clean all

RUN docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install opcache && \
    docker-php-ext-enable opcache

