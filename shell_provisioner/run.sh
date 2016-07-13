#!/bin/bash

# Shell provisioner

MODULE_PATH='/vagrant/shell_provisioner/module'
CONFIG_PATH='/vagrant/shell_provisioner/config'

# IP for the vagrant VM
GUEST_IP='192.168.33.10'

# Set the variables below for your project

# 1) Set to your app's local domainname
APP_DOMAIN='j2sp.dev'

# 2) Modify config/apache/app.vhost.conf and config/apache/hosts.txt to use the
#    values for APP_DOMAIN and GUEST_IP set above

# 3) App DB name and credentials
APP_DBNAME='j2sp'
APP_DBUSER='root'
APP_DBPASSWORD='vagrant'

# Hostname used by postfix
POSTFIX_HOSTNAME='j2sp.dev'

# Solr cores
SOLR_CORE_1='j2sp'

# Adding an entry here executes the corresponding .sh file in MODULE_PATH
DEPENDENCIES=(
    debian
    tools
    vim
    php
    mysql
    apache
    phpmyadmin
    blackfire
    grunt
    # drush
    # app_drupal8
    app_symfony
    mailcatcher
    # solr
)

for MODULE in ${DEPENDENCIES[@]}; do
    source ${MODULE_PATH}/${MODULE}.sh
done

echo "cd /vagrant/" >> /home/vagrant/.bashrc