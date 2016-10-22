#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
#Read basic information for proxy
read -p "What's the original server ip and port? (exp: http://1.1.1.1:80): " res
read -p "What's the domain you want to use as the CDN doamin?(exp: ixh.me): " dn
#choose whether to use SSL.
while :; do echo
    read -p "Set up ssl to this proxy domain? ('y' or 'n'): " ifssl
    if [[ ! $ifssl =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        if [ "$ifssl" == 'y' ];then
        	echo "You choose to install SSL certificate."
        	read -p "Please input the location of the KEY (exp: /root/ssl/ixh.me.key): " key
        	read -p "Please input the location of the CRT (exp: /root/ssl/ixh.me.crt): " crt
        	while :; do echo
        		read -p "Redirect all HTTP to HTTPS ? ('y' or 'n'): " ifforcessl
        		if [[ ! $ifforcessl =~ ^[y,n]$ ]];then
        		echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    			else
    				break
    			fi
        	done
        	break
        else
        	echo "You choose NOT to install SSL certificate."
        	break
        fi
    fi
done
#Configure Nginx
cd /usr/local/nginx/conf/vhost/
rm -rf $dn.conf
touch $dn.conf
echo "server {  " > $dn.conf
echo "listen 80;" >> $dn.conf
if [ "$ifssl" == 'y' ];then
	echo "listen 443 ssl http2;" >> $dn.conf
	echo "ssl_certificate $crt;" >> $dn.conf
	echo "ssl_certificate_key $key;" >> $dn.conf
	echo "ssl_protocols TLSv1 TLSv1.1 TLSv1.2;" >> $dn.conf
	echo "ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;" >> $dn.conf
	echo "ssl_prefer_server_ciphers on;" >> $dn.conf
	echo "ssl_session_timeout 10m;" >> $dn.conf
	echo "ssl_session_cache builtin:1000 shared:SSL:10m;" >> $dn.conf
	echo "ssl_buffer_size 1400;" >> $dn.conf
	echo "add_header Strict-Transport-Security max-age=15768000;" >> $dn.conf
	echo "ssl_stapling on;" >> $dn.conf
	echo "ssl_stapling_verify on;" >> $dn.conf
fi

if [ "$ifforcessl" == 'y' ];then
	echo "if ($ssl_protocol = "") { return 301 https://\$host\$request_uri; }" >> $dn.conf
fi
echo "server_name $dn;" >> $dn.conf
echo "location / {" >> $dn.conf
echo "proxy_set_header   X-Real-IP \$remote_addr;" >> $dn.conf
echo "proxy_set_header   Host      \$http_host;" >> $dn.conf
echo "proxy_pass         $res;" >> $dn.conf
echo "}" >> $dn.conf
echo "}" >> $dn.conf

#Reload the Nginx to apply the chages to the Vhost
service nginx reload
