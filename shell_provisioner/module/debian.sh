#!/bin/bash

# Debian

# Locales
sed -i 's/# nl_BE.UTF-8 UTF-8/nl_BE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
# echo 'LANG=nl_BE.UTF-8' > /etc/default/locale

# Timezone
echo "Europe/Brussels" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Custom bash prompt
echo "PS1='[\u@\h-\[\033[00;34m\]dev\[\033[00m\] \w]\n\\$ '" >> /etc/bash.bashrc
echo "PS1='[\u@\h-\[\033[00;34m\]dev\[\033[00m\] \w]\n\\$ '" >> /home/vagrant/.bashrc

# arrow up/down history behavior
cat << EOF >/root/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on
EOF
cp /root/.inputrc /home/vagrant
chown vagrant:vagrant /home/vagrant/.inputrc

# Console keyboard
sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="be"/' /etc/default/keyboard
setupcon --force

# Host file
echo 127.0.0.1 $APP_DOMAIN >> /etc/hosts

# Add dotdeb repository
wget https://www.dotdeb.org/dotdeb.gpg
sudo apt-key add dotdeb.gpg

cat << EOF >/etc/apt/sources.list.d/dotdeb.list
deb http://packages.dotdeb.org jessie all
deb-src http://packages.dotdeb.org jessie all
EOF

# Sync package index files
apt-get update

