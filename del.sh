#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
#Read basic information 
echo "Domain List in system"
cd /usr/local/nginx/conf/vhost/
ls
read -p "What's the domain you want to delete?(exp: ixh.me): " dn
rm -rf $dn.conf
service nginx reload
echo "Success"
