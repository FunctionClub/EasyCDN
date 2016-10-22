
#CDN 服务器自动安装脚本
##说明
采用Oneinstack包安装配置Nginx，此脚本方便做反向代理，CDN静态缓存资源（开发中）。
##用法
1.使用install.sh进行一键Nginx安装
2.使用add.sh将本机变成CDN节点进行转发

./add.sh

What's the original server ip and port? (exp: http://1.1.1.1:80):
<strong>这里输入你的源站IP和端口，例如： http://1.1.1.1:80</strong>

What's the domain you want to use as the CDN doamin?(exp: ixh.me):
<strong>这里输入本机反向代理的域名，例如：ixh.me</strong>

Set up ssl to this proxy domain? ('y' or 'n'): 
<strong>选择y或者n来选择本机是否启用SSL</strong>

如果输入y则开始配置如下：

Please input the location of the KEY
Please input the location of the CRT
<strong>这里分别输入你的绑定的反向代理域名SSL私钥和证书文件绝对路径</strong>

Redirect all HTTP to HTTPS ? ('y' or 'n')
<strong>选择y或者n来选择是否启用强制跳转所有http至https协议</strong>
