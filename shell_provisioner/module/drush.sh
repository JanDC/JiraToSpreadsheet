#!/bin/bash

# Drush
su - vagrant -c "composer global require drush/drush:8.*"
ln -s /home/vagrant/.composer/vendor/bin/drush /usr/bin/drush

# Drupal Console
su - vagrant -c "composer global require drupal/console:@stable"
ln -s /home/vagrant/.composer/vendor/bin/drupal /usr/bin/drupal
su - vagrant -c "drupal init --override"
echo "source \"/home/vagrant/.console/console.rc\" 2>/dev/null" >> /home/vagrant/.bashrc
su - vagrant -c "drupal check"

su - vagrant -c "composer global update"