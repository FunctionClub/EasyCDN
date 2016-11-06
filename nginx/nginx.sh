#Config
nginx_version=1.10.2
openssl_version=1.0.2j
pcre_version=8.39
cachepurge_version=2.3
run_user=www
nginx_install_dir=/usr/local/nginx
wwwroot_dir=/data/wwwlogs
wwwlogs_dir=/data/wwwroot
www_dir=/data
#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ]; then
  OS=CentOS
  [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
  [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
  [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ]; then
  OS=CentOS
  CentOS_RHEL_version=6
elif [ -n "$(grep 'bian' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Debian" ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep 'Deepin' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Deepin" ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep 'Kali GNU/Linux Rolling' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Kali" ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  if [ -n "$(grep 'VERSION="2016.*"' /etc/os-release)" ]; then
    Debian_version=8
  else
    echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
    kill -9 $$
  fi
elif [ -n "$(grep 'Ubuntu' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Ubuntu" -o -n "$(grep 'Linux Mint' /etc/issue)" ]; then
  OS=Ubuntu
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
  [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
elif [ -n "$(grep 'elementary' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'elementary' ]; then
  OS=Ubuntu
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Ubuntu_version=16
else
  echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
  kill -9 $$
fi

cd /root
mkdir nginx
cd nginx
# install basic things
if [ ${OS}=Ubuntu ];then
	apt-get update -y && apt-get upgrade -y
	cd /root/nginx
	echo "Install basic Toolkit"
	apt-get install libpcre3 libpcre3-dev unzip git zlib1g-dev build-essential gcc -y
	echo "Install Zlib"
	cd /root/nginx
	wget http://zlib.net/zlib-1.2.8.tar.gz
	tar -zxf zlib-1.2.8.tar.gz
	cd zlib*
	make clean
	./configure --shared
	make test
	make install
	cp zutil.h /usr/local/include
	cp zutil.c /usr/local/include
	cd /root/nginx
	fi

if [ ${OS}=CentOS ];then
    yum -y install gcc gcc-c++
    cd /root/nginx
	echo "Install basic Toolkit"
	yum -y install pcre-devel zlib unzip git patch
	echo "Install Zlib"
	wget http://zlib.net/zlib-1.2.8.tar.gz
	tar -zxf zlib-1.2.8.tar.gz
	cd zlib*
	make clean
	./configure --shared
	make test
	make install
	cp zutil.h /usr/local/include
	cp zutil.c /usr/local/include
	cd /root/nginx
fi





#Download Something
wget http://nginx.org/download/nginx-$nginx_version.tar.gz
wget https://www.openssl.org/source/openssl-$openssl_version.tar.gz
wget http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz
wget http://labs.frickle.com/files/ngx_cache_purge-$cachepurge_version.tar.gz

  id -u $run_user >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user
  
  tar xzf pcre-$pcre_version.tar.gz
  tar xzf nginx-$nginx_version.tar.gz
  tar xzf openssl-$openssl_version.tar.gz
  tar zxf ngx_cache_purge-$cachepurge_version.tar.gz

  cd  nginx-$nginx_version
  [ ! -d "$nginx_install_dir" ] && mkdir -p $nginx_install_dir
  ./configure --prefix=$nginx_install_dir --user=$run_user --group=$run_user --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module --with-openssl=../openssl-$openssl_version --with-pcre=../pcre-$pcre_version --with-pcre-jit --add-module=../ngx_cache_purge-$cachepurge_version

  make -j 4 && make install
  if [ -e "$nginx_install_dir/conf/nginx.conf" ]; then
    popd 
    rm -rf nginx-$nginx_version
    echo "${CSUCCESS}Nginx installed successfully! ${CEND}"
  else
    rm -rf $nginx_install_dir
    echo "${CFAILURE}Nginx install failed, Please Contact the author! ${CEND}"
    kill -9 $$
  fi
  
  cd /root/nginx
  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$nginx_install_dir/sbin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $nginx_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$nginx_install_dir/sbin:\1@" /etc/profile
  . /etc/profile
  
  [ "$OS" == 'CentOS' ] && { /bin/cp Nginx-init-CentOS /etc/init.d/nginx; chkconfig --add nginx; chkconfig nginx on; }
  [[ $OS =~ ^Ubuntu$|^Debian$ ]] && { /bin/cp Nginx-init-Ubuntu /etc/init.d/nginx; update-rc.d nginx defaults; }

  sed -i "s@/usr/local/nginx@$nginx_install_dir@g" /etc/init.d/nginx
  
  mv $nginx_install_dir/conf/nginx.conf{,_bk}
  /bin/cp nginx.conf $nginx_install_dir/conf/nginx.conf
  cat > $nginx_install_dir/conf/proxy.conf << EOF
proxy_connect_timeout 300s;
proxy_send_timeout 900;
proxy_read_timeout 900;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 128k;
proxy_redirect off;
proxy_hide_header Vary;
proxy_set_header Accept-Encoding '';
proxy_set_header Referer \$http_referer;
proxy_set_header Cookie \$http_cookie;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
EOF
  sed -i "s@$wwwroot_dir/default@$wwwroot_dir/default@" $nginx_install_dir/conf/nginx.conf
  sed -i "s@wwwlogs_dir@$wwwlogs_dir@g" $nginx_install_dir/conf/nginx.conf
  sed -i "s@^user www www@user $run_user $run_user@" $nginx_install_dir/conf/nginx.conf
  
  # logrotate nginx log
  cat > /etc/logrotate.d/nginx << EOF
$wwwlogs_dir/*nginx.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
  endscript
}
EOF

mkdir $www_dir
mkdir $wwwlogs_dir
mkdir $wwwroot_dir
mkdir $wwwroot_dir/default
touch $wwwlogs_dir/error_nginx.log
touch $wwwroot_dir/default/index.html
chown -R $run_user $www_dir
service nginx start
cd ../
rm -rf nginx
