#!/bin/bash

# Drupal application

# Build frontend
cd /vagrant/htdocs/themes/itr_theme/.npm
sudo npm install
grunt build

cd -
