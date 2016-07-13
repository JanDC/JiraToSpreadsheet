#!/bin/bash

# PHP

apt-get -y install php7.0-cli php7.0-fpm php7.0-dev php7.0-curl php7.0-intl \
    php7.0-mysql php7.0-sqlite3 php7.0-gd php7.0-mbstring php7.0-xml

sed -i 's/;date.timezone.*/date.timezone = Europe\/Brussels/' /etc/php/7.0/fpm/php.ini
sed -i 's/;date.timezone.*/date.timezone = Europe\/Brussels/' /etc/php/7.0/cli/php.ini
sed -i 's/^user = www-data/user = vagrant/' /etc/php/7.0/fpm/pool.d/www.conf
sed -i 's/^group = www-data/group = vagrant/' /etc/php/7.0/fpm/pool.d/www.conf

# apcu

## Build
git clone https://github.com/krakjoe/apcu.git
pushd apcu
git checkout -b v5.1.2 v5.1.2
phpize
./configure
make
make install

## Install
cat << EOF >/etc/php/7.0/mods-available/apcu.ini
extension=apcu.so
EOF
ln -s /etc/php/7.0/mods-available/apcu.ini /etc/php/7.0/cli/conf.d/20-apcu.ini
ln -s /etc/php/7.0/mods-available/apcu.ini /etc/php/7.0/fpm/conf.d/20-apcu.ini
popd

# xdebug

## Build
git clone git://github.com/xdebug/xdebug.git
pushd xdebug
git checkout -b XDEBUG_2_4_0 XDEBUG_2_4_0
phpize
./configure
make
make install

cat << EOF >/etc/php/7.0/mods-available/xdebug.ini
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_host=192.168.33.1
xdebug.max_nesting_level=256
; xdebug.profiler_enable=1
; xdebug.profiler_output_dir=/vagrant/dumps
EOF
ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini
ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/fpm/conf.d/20-xdebug.ini
popd

service php7.0-fpm restart

# composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin
ln -s /usr/bin/composer.phar /usr/bin/composer

# phpunit
wget -P /usr/bin https://phar.phpunit.de/phpunit.phar
chmod +x /usr/bin/phpunit.phar
ln -s /usr/bin/phpunit.phar /usr/bin/phpunit
