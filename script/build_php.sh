#!/bin/sh

# usage - ./build_php.sh 5.4.38

# 当前目录
DIR="$( cd "$( dirname "$0" )" && pwd )"

# PHP版本
VERSION=$1
VMAJOR=`echo ${VERSION%%.*}`
VMINOR=`echo ${VERSION%.*}`
VMINOR=`echo ${VMINOR#*.}`
VPATCH=`echo ${VERSION##*.}`
VCOMP=`printf "%02d%02d%02d\n" $VMAJOR $VMINOR $VPATCH`

TAR_SRC_FILE="php-$VERSION.tar.bz2"
SRCDIR="/usr/local/src"
TAR_FILE_SRC="$SRCDIR/$TAR_SRC_FILE"
SRC="/usr/local/src/php-$VERSION"

# 创建源码存放路径
if [ ! -d "$SRCDIR" ]; then
    mkdir -p $SRCDIR
fi

# 下载PHP源码并解压
URL="http://cn2.php.net/get/php-$VERSION.tar.bz2/from/this/mirror"
cd "$SRCDIR" && wget "$URL" -O "$TAR_SRC_FILE"

if [ ! -f "$TAR_FILE_SRC" ]; then
    echo "Fetching sources from museum failed"
    echo $URL
    exit 1
fi

tar xjvf "$TAR_FILE_SRC"

if [ $? -gt 0 ]; then
    echo "can not download php source code failed."
    exit 1
fi

# 安装路径
BASEPATH="/usr/local"

PREFIX="$BASEPATH/php/$VERSION"
SBIN_DIR="$BASEPATH/php/$VERSION"
CONF_DIR="$BASEPATH/php/$VERSION"
CONFD_DIR="$BASEPATH/php/$VERSION/conf.d"
MAN_DIR="$BASEPATH/php/$VERSION/share/man"

if [ ! -d "CONFD_DIR" ]; then
    mkdir -p $CONFD_DIR
fi

# main configuration
PHP_CONF="--config-cache \
    --prefix=$PREFIX \
    --sbindir=$SBIN_DIR \
    --sysconfdir=$CONF_DIR \
    --localstatedir=/var \
    --with-layout=GNU \
    --with-config-file-path=$CONF_DIR \
    --with-config-file-scan-dir=$CONFD_DIR \
    --disable-rpath \
    --with-libdir=lib64 \
    --mandir=$MAN_DIR
"

# additional
ADD_CONF="--enable-ftp \
    --enable-exif \
    --enable-calendar \
    --with-snmp=/usr \
    --with-pspell \
    --with-tidy \
    --with-xmlrpc
"

# define extension configuration
EXT_CONF="--enable-mbstring \
    --enable-mbregex \
    --enable-phar \
    --enable-posix \
    --enable-soap \
    --enable-sockets \
    --enable-sysvmsg \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-zip \
    --enable-inline-optimization \
    --enable-intl \
    --with-icu-dir=/usr \
    --with-curl=/usr/bin \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=shared,/usr \
    --with-xpm-dir=/usr \
    --with-freetype-dir=/usr \
    --with-bz2=/usr \
    --with-gettext \
    --with-iconv-dir=/usr \
    --with-mcrypt=/usr \
    --with-mhash \
    --with-zlib-dir=/usr \
    --with-regex=php \
    --with-pcre-regex \
    --with-openssl \
    --with-openssl-dir=/usr/bin \
    --with-mysql-sock=/var/run/mysqld/mysqld.sock \
    --with-mysqli=mysqlnd \
    --with-sqlite3 \
    --with-pdo-mysql=mysqlnd \
    --with-pdo-sqlite
"

# adapt fpm user and group
PHP_FPM_CONF="--enable-fpm \
    --with-fpm-user=www \
    --with-fpm-group=www
"

# php-fpm & CLI module
cd "$SRC"
./configure $PHP_CONF \
    --disable-cgi \
    --with-readline \
    --enable-cli \
    --with-pear \
    $PHP_FPM_CONF \
    $ADD_CONF \
    $EXT_CONF

if [ $? -gt 0 ]; then
    echo configure.sh failed.
    exit 2
fi

make && make install

if [ $? -gt 0 ]; then
    echo php-fpm install failed.
    exit 3
fi

# config file
cp $SRC/php.ini-development $CONF_DIR/php.ini
cp $CONF_DIR/php-fpm.conf.default $CONF_DIR/php-fpm.conf

# sed -i '/listen = 127.0.0.1:9000/clisten = 127.0.0.1:90$VMAJOR$VMINOR/g' /usr/local/php/5.4.38/php-fpm.conf
ln -s $PREFIX/php-fpm /usr/local/sbin/php-fpm

groupadd -f -g 1001 -r www
useradd -g 1001 -u 1001 -M -G www -r -s /sbin/nologin www