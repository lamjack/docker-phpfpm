FROM tutum/centos:centos7

MAINTAINER JackLam<jack@wizmacau.com>

RUN yum install -y yum-fastestmirror &&\
  yum -y install make automake wget tar bzip2 openssh-clients &&\
  yum -y install gcc libxml2-devel openssl-devel bzip2-devel curl-devel libjpeg-devel libpng-devel libXpm-devel freetype-devel gcc-c++ libmcrypt-devel libicu-devel aspell-devel readline-devel net-snmp-devel libtidy-devel libtool-ltdl-devel

RUN yum -y install python-pip && pip install supervisor

COPY script/ /root/script/

WORKDIR /root/script

RUN ./build_php.sh 5.4.38
RUN ./create_webuser.sh

VOLUME ["/home/webuser/www", "/home/webuser/.ssh"]

ADD supervisord.conf /usr/etc/supervisord.conf

EXPOSE 22
EXPOSE 9000

CMD ["/usr/bin/supervisord"]