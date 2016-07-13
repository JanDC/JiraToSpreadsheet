#!/bin/bash

# Grunt

# Install node.js
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs

# Update node packaged modules
npm update -g npm

# Install grunt
npm install -g grunt-cli

# nmp install dependencies
apt-get install -y g++ git
