#!/bin/bash

# Install Tomcat
apt-get install -y tomcat7 tomcat7-admin

# Add admin user
sed -i 's/<\/tomcat-users>/  <user username="vagrant" password="vagrant" roles="manager-gui,admin-gui"\/>\n<\/tomcat-users>/' /var/lib/tomcat7/conf/tomcat-users.xml

# Install Solr
wget http://archive.apache.org/dist/lucene/solr/4.6.1/solr-4.6.1.tgz
tar xzvf solr-4.6.1.tgz
mv solr-4.6.1 /usr/share/solr
mkdir -p /usr/share/solr/live/solr
cp /usr/share/solr/example/webapps/solr.war /usr/share/solr/live/solr/solr.war
chown -R tomcat7:tomcat7 /usr/share/solr

# Configure logging
cp /usr/share/solr/example/lib/ext/* /usr/share/tomcat7/lib
cp /usr/share/solr/example/resources/log4j.properties /usr/share/tomcat7/lib

sed -i 's#solr.log=.*#solr.log=/var/log/solr#' /usr/share/tomcat7/lib/log4j.properties
mkdir /var/log/solr && chown tomcat7:tomcat7 /var/log/solr

cat << EOF >/etc/logrotate.d/solr
/var/log/solr/solr.log {
  copytruncate
  daily
  rotate 5
  compress
  missingok
  create 644 tomcat7 adm
}
EOF

cat << EOF >/etc/tomcat7/Catalina/localhost/solr.xml
<Context docBase="/usr/share/solr/live/solr/solr.war" debug="0" crossContext="true">
    <Environment name="solr/home" type="java.lang.String" value="/usr/share/solr/live/solr" override="true" />
</Context>
EOF

# Copy solr.xml
cp /usr/share/solr/example/solr/solr.xml /usr/share/solr/live/solr/solr.xml

# Add core 1
mkdir -p /usr/share/solr/live/solr/cores/${SOLR_CORE_1}/data/index
mkdir -p /usr/share/solr/live/solr/cores/${SOLR_CORE_1}/conf
cp -R /usr/share/solr/example/solr/collection1/conf/* /usr/share/solr/live/solr/cores/${SOLR_CORE_1}/conf/
mkdir -p /vagrant/solr/${SOLR_CORE_1}
ln -s /usr/share/solr/live/solr/cores/${SOLR_CORE_1}/conf /vagrant/solr/${SOLR_CORE_1}/solr_core_conf
echo "name=${SOLR_CORE_1}" >> /usr/share/solr/live/solr/cores/${SOLR_CORE_1}/core.properties
chown -R tomcat7:tomcat7 /usr/share/solr/live/solr/cores/${SOLR_CORE_1}
chown -R vagrant:tomcat7 /usr/share/solr/live/solr/cores/${SOLR_CORE_1}/conf/

# Restart tomcat 
service tomcat7 restart
