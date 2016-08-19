#!/bin/bash -eux

pvcreate /dev/sdb
vgcreate vg_es /dev/sdb
lvcreate -L500 -nlv_es vg_es

mkfs.xfs /dev/vg_es/lv_es
mkdir -p /var/lib/elasticsearch
echo "/dev/vg_es/lv_es /var/lib/elasticsearch xfs defaults,noatime 1 2" >> /etc/fstab
mount -a

#show the current status
mount

# Install EPEL repository and software
yum -y install epel-release wget

wget -q -O /tmp/jdk-8u102-linux-x64.rpm --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.rpm
rpm -ivh /tmp/jdk-8u102-linux-x64.rpm

yum install -y redis
chkconfig redis on
service redis start

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
cat<<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=https://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF
yum install -y elasticsearch
chkconfig --add elasticsearch
chkconfig elasticsearch on
service elasticsearch start

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
cat<<EOF > /etc/yum.repos.d/kibana.repo
[kibana-4.5]
name=Kibana repository for 4.5.x packages
baseurl=http://packages.elastic.co/kibana/4.5/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF
yum install -y kibana
chkconfig --add kibana
service kibana start
chkconfig kibana on

