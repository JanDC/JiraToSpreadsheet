#!/bin/bash

# Symfony application

cd /vagrant/htdocs

# Install vendors
composer.phar install

# Build frontend
cd web/.npm
npm install
grunt build

cd -
