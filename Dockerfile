FROM php:7.4-fpm

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
    blackfire-php \
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
    # MSMTP for sending outbound email
    msmtp-mta \
    # Required for zip PHP extension
    zlib1g-dev \
    zip \
  && rm -rf /var/lib/apt/lists/*

# Install and configure PHP Extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
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
    # Required by php-amqplib/php-amqplib package which is still in use by Conductor
    # Also required for magento/ece-tools related to Magento Cloud
    sockets \
    xsl \
    # zip ext produces warning: implicit declaration of function 'getpid'
    zip

# Install Xdebug
RUN pecl install xdebug-2.9.4

# Configure PHP defaults
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY conf.d /usr/local/etc/php/conf.d

# Set up mail command to run through msmtp, by default
COPY etc/mail.rc /etc/mail.rc

## Setup www-data to match our normal user
RUN groupmod -g 800 www-data
RUN usermod --home /home/www-data www-data
COPY --chown=www-data:www-data home /home/www-data
RUN chmod 0600 /home/www-data/.msmtprc

# Set up entrypoint
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]
