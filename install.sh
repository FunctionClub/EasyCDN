#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Install Nginx via Oneinstack(https://github.com/lj2007331/oneinstack)
cd /root
wget http://mirrors.linuxeye.com/oneinstack.tar.gz && tar -xf oneinstack.tar.gz && cd oneinstack/
rm -rf install.sh && wget http://download.ipatrick.cn/ghost/install.sh && chmod +x install.sh
./install.sh

mkdir /usr/local/nginx/conf/vhost/

#Clean useless things.
rm -rf /root/oneinstack-1.4
rm -rf /root/V1.4.tar.gz