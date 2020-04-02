FROM php:7.3-fpm

# Prevents error messages related to using non tty terminal
ARG DEBIAN_FRONTEND=noninteractive
# Prevents error message when piping gpg key into apt-get
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Increment to force a new build
ARG BUILD=1

LABEL maintainer1="Kirk Madera <kirk.madera@rmgmedia.com>" \
  maintainer2="Matthew Feinberg <matthew.feinberg@rmgmedia.com>" \
  maintainer3="Valentin Peralta <valentin.peralta@rmgmedia.com>"

## Install apt related packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    # Prevents error message "debconf: delaying package configuration, since apt-utils is not installed"
    apt-utils \
    # Required for "apt-key add" to work
    gnupg2 \
  && rm -rf /var/lib/apt/lists/*

# Add Blackfire repo
RUN curl https://packages.blackfire.io/gpg.key | apt-key add - \
    && echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list

## Install packages
RUN apt-get update \
  && apt-get install -y \
    bash-completion \
    blackfire-php \
    cron \
    # Required for hirak/prestissimo Composer plugin installation
    git \
    htop \
    # Required for gd PHP extension
    libfreetype6-dev \
    # Required for gd PHP extension
    libjpeg-dev \
    # Required for gd PHP extension
    libpng-dev \
    # Required for xsl PHP extension
    libxslt-dev \
    # Required for soap PHP extension
    libxml2-dev \
    # Required for zip PHP extension
    libzip-dev \
    mariadb-client \
    mydumper \
    nano \
    openssh-client \
    # Installs redis-cli
    redis-tools \
    telnet \
    tig \
    # Required for hirak/prestissimo Composer plugin installation
    unzip \
    vim \
    # Required for Composer installation && hirak/prestissimo Composer plugin installation
    wget \
    # Required for zip PHP extension
    zlib1g-dev \
    zip \
  && rm -rf /var/lib/apt/lists/*

# Install and configure PHP Extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib \
  && docker-php-ext-install \
    bcmath \
    gd \
    # Produces warning: 'uidna_IDNToASCII_57' is deprecated
    # and warning: inline function 'grapheme_memrchr_grapheme' declared but never defined
    intl \
    opcache \
    # Required for Conductor to run parallel asset upload/download
    pcntl \
    pdo_mysql \
    soap \
    xsl \
    # zip ext produces warning: implicit declaration of function 'getpid'
    zip

# Install Xdebug
RUN pecl install xdebug-2.9.4

# Configure PHP defaults
COPY php.ini /usr/local/etc/php/php.ini
COPY conf.d /usr/local/etc/php/conf.d

# Install Composer
COPY install-composer.sh /tmp
RUN bash /tmp/install-composer.sh && rm /tmp/install-composer.sh

# Setup webuser
RUN groupadd -r -g 800 nginx \
 && useradd -d /home/webuser -m -u 1000 -g nginx -s /bin/bash webuser

WORKDIR /home/webuser
COPY --chown=webuser:nginx home .
RUN echo "export PATH=\$HOME/bin/robofirm:\$HOME/bin/robofirm/vendor/bin:\$PATH >> .bashrc"

USER webuser

# Install hirak/prestissimo Composer plugin for webuser
RUN composer global require hirak/prestissimo

# Switch back to root
USER root
