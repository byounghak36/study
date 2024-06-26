php 설치
(참조 : https://hoing.io/archives/8218)
----------------------------------------------------------------------
사전 yum 설치

yum -y install curl-devel libpng \
libpng-devel libjpeg libjpeg-devel \
libwebp libwebp-devel libXpm \
libXpm-devel  \
autoconf curl  \
freetype freetype-devel gd gd-devel \
libjpeg libjpeg-devel libmcrypt \
libmcrypt-devel libtool-ltdl-devel \
libzip libzip-devel \
oniguruma-devel gcc-c++ gcc \
libxml2-devel libxml2 libcurl \
libcurl-devel bzip2-devel sqlite-devel \
oniguruma-devel
----------------------------------------------------------------------
# Error 1

checking for gdlib >= 2.1.0... no configure: error: Package requirements (gdlib >= 2.1.0) were not met: Requested 'gdlib >= 2.1.0' but version of gd-devel is 2.0.34

[root]]# yum list | grep gd-devel
gd-devel.x86_64 2.0.35-26.el7 @base

yum repository 에서 받을 수 있는 버전이 설치에 필요한 요구 버전보다 낮았습니다 그래서 소스 컴파일로 패키지를 설치 하였습니다.
[root]]# wget https://github.com/libgd/libgd/releases/download/gd-2.3.0/libgd-2.3.0.tar.gz
[root]]# tar zxvf libgd-2.3.0.tar.gz
[root]]# cd libgd-2.3.0
[root]]# ./configure --prefix=/usr/local/libgd-2.3.0
[root]]# make ; make install
----------------------------------------------------------------------
# Error 2

checking for libzip >= 0.11 libzip != 1.3.1 libzip != 1.7.0... no
configure: error: Package requirements (libzip >= 0.11 libzip != 1.3.1 libzip != 1.7.0) were not met:

No package 'libzip' found
No package 'libzip' found
No package 'libzip' found

yum 으로 설되는 libzip libzip-devel 패키지의 버전이 요구 버전 보다 낮아서 libzip 을 compile 설치 하였습니다.

문제는 libzip 을 cmake 하기 위해서 또 필요한 cmake 버전이 충족치(낮아서) 않아서 cmake도 컴파일로 설치를 해야 했습니다.
 - libzip 필요 CMake 버전 관련 에러 메세지
    CMake Error at CMakeLists.txt:1 (cmake_minimum_required):
    CMake 3.0.2 or higher is required. You are running version 2.8.12.2


# Error2-1 : cmake-3.19 설치
[root]# yum -y install gcc-c++
[root]# wget https://github.com/Kitware/CMake/releases/download/v3.25.2/cmake-3.25.2.tar.gz
[root]# tar zxvf cmake-3.25.2.tar.gz
[root]# cd cmake-3.25.2/
[root]# ./configure --prefix=/usr/local/cmake-3.25.2
[root]# make;make install

# Error2-2 : libzip 설치
[root]# wget https://libzip.org/download/libzip-1.7.3.tar.gz
[root]# tar zxvf libzip-1.7.3.tar.gz
[root]# cd libzip-1.7.3
[root]# /usr/local/cmake-3.19.0-rc1/bin/cmake -DCMAKE_INSTALL_PREFIX=/usr/local/libzip-1.7.3
[root]# make;make install

# Error3-1

----------------------------------------------------------------------
설치순서

wget https://www.php.net/distributions/php-8.2.1.tar.gz
tar xvzf php-8.2.1.tar.gz
export PKG_CONFIG_PATH=/usr/local/libgd-2.3.0/lib/pkgconfig:/usr/local/libzip-1.7.3/lib64/pkgconfig
./configure --prefix=/usr/local/php-8.2.1 \
--with-config-file-path=/etc --enable-mysqlnd \
--with-pdo-mysql=/usr/local/mysql --enable-soap \
--enable-mbstring --with-zip --enable-exif \
--enable-gd --with-external-gd \
--with-webp --with-jpeg \
--with-libxml --enable-gd-jis-conv --with-zlib-dir \
--with-freetype --with-xpm \
--enable-sockets --with-openssl=/usr/local/ssl/ --with-openssl-dir=/usr/local/ssl/ --with-zlib \
--with-gettext --enable-sigchild --with-iconv \
--enable-opcache --enable-fpm \
--with-fpm-user=apache --with-fpm-group=apache \
--with-pdo_mysql --with-curl --enable-exif \
--enable-bcmath --enable-mbstring=all \
--with-mysqli=/usr/local/mysql/bin/mysql_config

./configure \
--prefix=/usr/local/php-8.2.1 \
--with-apxs2=/usr/local/apache/bin/apxs \
--with-config-file-path=/usr/local/apache/conf \
--with-pdo-mysql=/usr/local/mysql \
--with-openssl \
--with-openssl-dir=/usr/local/ssl \
--enable-zts

'/usr/local/src/php-8.2.1/configure' '--with-apxs2=/usr/local/httpd2/bin/apxs' '--with-config-file-path=/usr/local/http2/conf' '--with-pdo-mysql=/usr/local/mysql' '--with-openssl' '--with-openssl-dir=/usr/local/ssl' '--enable-zts'

Apache 설정 변경

/etc/httpd/conf/httpd.conf  파일을 수정 

[root]# vi /etc/httpd/conf/httpd.conf


ServerName www.example.com:80
-> 주석 해제


아래 Directory 사이의 내용을 변경 합니다.
<Directory "/var/www/html">
        .... 사이의 내용...
</Directory>


#Options Indexes FollowSymLinks
-> 주석 처리 후 아래 내용으로 입력

Options MultiViews FollowSymLinks
-> 내용 추가 


#AllowOverride None
-> 주석 처리 후 아래 내용으로 입력

AllowOverride All
-> 내용 추가

=> 저장 후 편집 완료 합니다  :wq











