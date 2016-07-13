#!/bin/bash

# Apache

apt-get install -y apache2 libapache2-mod-fcgid

a2enmod rewrite expires headers proxy proxy_http proxy_fcgi actions fastcgi alias ssl

# OpenSSL
echo -n 'cn=' > /tmp/openssl.payload
cat /vagrant/shell_provisioner/config/hosts.txt | grep -v '^#' | cut -d' ' -f2 | grep -v '^$' | sed -n '1p' | tr '\n' '&' >> /tmp/openssl.payload
echo -n 'acn=' >> /tmp/openssl.payload
cat /vagrant/shell_provisioner/config/hosts.txt | grep -v '^#' | cut -d' ' -f2 | grep -v '^$' | sed -n '1!p' | tr '\n' ' ' >> /tmp/openssl.payload

curl -X POST -d@/tmp/openssl.payload http://controller.testing.intracto.local/ca/createcert.php > cert.tar

tar --no-same-owner -xvf cert.tar
mv ${APP_DOMAIN}.crt /etc/ssl/certs/${APP_DOMAIN}.crt
mv ${APP_DOMAIN}.key /etc/ssl/private/${APP_DOMAIN}.key
mv ${APP_DOMAIN}.all.crt /etc/ssl/certs/${APP_DOMAIN}.all.crt

# Activate vhost
a2dissite 000-default

chmod -R a+rX /var/log/apache2
sed -i 's/640/666/' /etc/logrotate.d/apache2
sed -i 's/Listen /Listen '${GUEST_IP}':/' /etc/apache2/ports.conf

cat ${CONFIG_PATH}/apache/app.vhost.conf > /etc/apache2/sites-available/${APP_DOMAIN}.conf

a2ensite ${APP_DOMAIN}.conf
service apache2 restart
