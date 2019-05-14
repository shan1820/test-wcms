############################################################
# Dockerfile to build WCMS container images
# Based on Ubuntu Xenial
############################################################

# Set the base image to Ubuntu
FROM ubuntu:xenial

# Allows installing of packages without prompting the user to answer any questions
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --assume-yes \
    software-properties-common \
    language-pack-en \
    curl \
    apt-transport-https

## Add the repo to get the latest PHP versions
RUN export LANG=en_US.UTF-8

## Need LC_ALL= otherwise adding the repos throws an ascii error.
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php

## Add the git repo so we can get the latest git (we need 2.9.2+)
RUN add-apt-repository ppa:git-core/ppa

RUN apt-get update

# Added so we can install 6.x branch of nodejs.
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# Install packages.
RUN apt-get install -y \
    vim \
    git \
    apache2 \
    php5.6 \
    php5.6-apc \
    php5.6-fpm \
    php5.6-xml \
    php5.6-simplexml \
    php5.6-mbstring \
    php5.6-cli \
    php5.6-mysql \
    php5.6-gd \
    php5.6-curl \
    php5.6-ldap \
    php5.6-mcrypt \
    php5.6-zip \
    php-pear \
    libapache2-mod-php5.6 \
    optipng \
    pdftk \
    jpegoptim \
    imagemagick \
    libapache2-mod-fcgid \
    libapache2-mod-fastcgi \
    curl \
    nano \
    mysql-client \
    openssh-server \
    wget \
    ruby-sass \
    ruby-compass \
    nodejs \
    dos2unix \
    supervisor

RUN apt-get clean

## enable rewrite and ssl for apache2
RUN a2enmod rewrite
RUN a2enmod ssl

## for Content Security Policy (CSP).
RUN a2enmod headers

## fcgid needed to run multiple versions of PHP under the same apache.
## RUN a2enmod fcgid

## enable mcrypt
RUN phpenmod mcrypt

## add upload progress
RUN apt-get install php-uploadprogress

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush 8.
RUN composer global require drush/drush:8.*
RUN composer global update
# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

## Enable apache mods
RUN a2enmod proxy_fcgi setenvif
RUN a2enconf php5.6-fpm
RUN service php5.6-fpm restart

## Make sure we are running php we selected
RUN update-alternatives --set php /usr/bin/php5.6
RUN a2enmod php5.6

## Install the drush registry_rebuild module
RUN drush @none dl registry_rebuild-7.x
