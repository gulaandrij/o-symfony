FROM php:7.1-fpm

RUN apt-get update
RUN apt-get install -y git zip unzip wget curl
RUN apt-get install -y libpq-dev libjpeg62-turbo-dev libfreetype6-dev libpng12-dev libpng-dev libgmp-dev
RUN docker-php-ext-install pdo opcache gd pdo_pgsql gmp bcmath
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ADD ./php.ini /usr/local/etc/php/
RUN pecl install apcu
RUN docker-php-ext-enable apcu
RUN curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/57.1/icu4c-57_1-src.tgz && tar -zxf /tmp/icu.tar.gz -C /tmp && cd /tmp/icu/source && ./configure --prefix=/usr/local && make && make install
RUN docker-php-ext-configure intl --with-icu-dir=/usr/local && docker-php-ext-install intl

WORKDIR /var/www/html