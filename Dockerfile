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

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

RUN mkdir -p /tmp/blackfire \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

RUN composer global require hirak/prestissimo

WORKDIR /var/www/html
