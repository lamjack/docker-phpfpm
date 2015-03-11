FROM tutum/centos:centos7

MAINTAINER JackLam<jack@wizmacau.com>

RUN yum install -y yum-fastestmirror&&\
  yum -y update &&\
  yum -y install wget tar bzip2 &&\
  yum -y install gcc gcc-c++ autoconf libjpeg-devel libpng-devel freetype-devel libxml2-devel zlib-devel glibc-devel glib2-devel bzip2-devel ncurses-devel curl curl-devel e2fsprogs-devel krb5-devel libidn-devel openssl openssl-devel pcre-devel zlib-devel gd-devel libjpeg-devel libpng-devel freetype-devel libxml2-devel curl-devel freetype-devel bison automake libxml* ncurses-devel libtool-ltdl-devel* mysql-devel libmcrypt-devel mhash-devel libXpm-devel libicu-devel aspell-devel readline-devel net-snmp-devel libtidy-devel

COPY script/ /root/script/

WORKDIR /root/script

RUN ./build_php.sh 5.4.38
RUN ./create_webuser.sh

VOLUME ["/home/webuser/www", "/home/webuser/.ssh"]

EXPOSE 22
EXPOSE 9000

RUN tail -f /var/log/yum.log