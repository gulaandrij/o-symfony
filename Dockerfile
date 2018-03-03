FROM php:7.2-fpm

RUN apt-get update
RUN apt-get install -y git zip unzip wget curl libpq-dev libjpeg62-turbo-dev libfreetype6-dev libpng-dev libgmp-dev
RUN docker-php-ext-install pdo opcache gd pdo_pgsql gmp bcmath zip
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ADD ./php.ini /usr/local/etc/php/
RUN pecl install apcu
RUN docker-php-ext-enable apcu

#RUN curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/60.2/icu4c-60_2-src.tgz && tar -zxf /tmp/icu.tar.gz -C /tmp && cd /tmp/icu/source && ./configure --prefix=/usr/local && make && make install
#RUN docker-php-ext-configure intl --with-icu-dir=/usr/local && docker-php-ext-install intl

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

RUN mkdir -p /tmp/blackfire \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

WORKDIR /var/www/html
