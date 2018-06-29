FROM php:apache

ENV GLPI_VER=9.3
ENV DATAINJECTION_VER=2.6.0

# Install php extensions and their requirements
RUN apt-get update && \
    apt-get install -y \
    libc-client-dev\
    libkrb5-dev\
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libldap-dev \
    libxml2-dev \
    libmcrypt-dev

RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mysqli \
    gd \
    ldap \
    xmlrpc \
    opcache

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

RUN pecl install apcu-5.1.11 && \
    docker-php-ext-enable apcu

# Install glpi
RUN apt-get update \
&&  apt-get --no-install-recommends install -y wget \
# && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*\
&&  wget -nv https://github.com/glpi-project/glpi/releases/download/${GLPI_VER}.0/glpi-${GLPI_VER}.tgz -O /tmp/glpi-${GLPI_VER}.tgz

RUN tar xf /tmp/glpi-${GLPI_VER}.tgz glpi --strip-components=1 -C /var/www/html/ \
&&  chown -R www-data:www-data /var/www/html/ \
&&  rm /tmp/glpi-${GLPI_VER}.tgz

# Install Plugin
RUN wget -nv \
    https://github.com/pluginsGLPI/datainjection/releases/download/${DATAINJECTION_VER}/glpi-datainjection-${DATAINJECTION_VER}.tar.bz2 \
    -O /tmp/glpi-datainjection-${DATAINJECTION_VER}.tar.bz2

RUN tar xf /tmp/glpi-datainjection-${DATAINJECTION_VER}.tar.bz2 -C /var/www/html/plugins \
&&  chown -R www-data:www-data /var/www/html/ \
&&  rm /tmp/glpi-datainjection-${DATAINJECTION_VER}.tar.bz2 

COPY entrypoint.sh /usr/bin/
ENTRYPOINT [ "/bin/bash", "/usr/bin/entrypoint.sh" ]
