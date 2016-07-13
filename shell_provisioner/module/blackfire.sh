#!/bin/bash

# blackfire.io - account service@intracto.com (see PMS for login)

# The PHP module is *DISABLED BY DEFAULT* if you want to activate the module do:
#     - sudo php5dismod xdebug
#     - sudo php5enmod blackfire
#     - sudo service php5-fpm restart

# Add the service
curl -s https://packagecloud.io/gpg.key | sudo apt-key add -
echo "deb http://packages.blackfire.io/debian any main" | sudo tee /etc/apt/sources.list.d/blackfire.list
apt-get update

# Install the Agent nand CLI tool
apt-get install -y blackfire-agent
blackfire-agent -register << EOF
6d272b57-a096-4b17-8fd4-78d64d4efc60
deec1896af04f821e494e08c0b8de6daa28e13acadbf9e692c57358c05330f4a
EOF
/etc/init.d/blackfire-agent restart

# Install the PHP probe
apt-get install -y blackfire-php
php5dismod blackfire
/etc/init.d/php5-fpm restart
