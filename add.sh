#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

read -p "What's the domain you want to proxy?[For Example: https://ixh.me:80 ]" res
read -p "What's the domain you want to use?[For Example: ixh.me ]" dn

#Configure Nginx
cd /usr/local/nginx/conf/vhost/
rm -rf $dn.conf
touch $dn.conf
echo "server {  " > $dn.conf
echo "server_name $dn;" >> $dn.conf
echo "location / {" >> $dn.conf
echo "proxy_set_header   X-Real-IP \$remote_addr;" >> $dn.conf
echo "proxy_set_header   Host      \$http_host;" >> $dn.conf
echo "proxy_pass         $res;" >> $dn.conf
echo "}" >> $dn.conf
echo "}" >> $dn.conf

#Reload the Nginx to apply the chages to the Vhost
service nginx reload
