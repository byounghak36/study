---
title: apache_install
tags:
  - apache
  - linux
date: <% tp.file.creation_date("YYYY_MM_DD") %>
Modify_Date: 
reference: 
link:
---

1) apr-1.7.0
/usr/local# wget http://mirror.navercorp.com/apache//apr/apr-1.7.0.tar.gz

2) apr-util-1.6.1
/usr/local# wget http://mirror.navercorp.com/apache//apr/apr-util-1.6.1.tar.gz

3) pcre-8.43
/usr/local# wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz/

/usr/local# tar xvfz apr-1.7.0.tar.gz
/usr/local# tar xvfz apr-util-1.6.1.tar.gz
/usr/local# tar xvfz pcre-8.45.tar.gz
/usr/local# tar xvfz httpd-2.4.53.tar.gz


## apr 설치
/usr/local# cd apr-1.7.0
/usr/local/apr-1.7.0# ./configure --prefix=/usr/local/apr
여기서 오류가 난다면
# cp -arp libtool libtoolT 다운로드를 해준다.

/usr/local/apr-1.7.0# make
/usr/local/apr-1.7.0# make install

## apr-util 설치
/usr/local# cd apr-util-1.6.1
/usr/local/apr-util-1.6.1# ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
/usr/local/apr-util-1.6.1# make
/usr/local/apr-util-1.6.1# make install

## pcre 설치
/usr/local# cd pcre-8.45
/usr/local/pcre-8.43# ./configure --prefix=/usr/local/pcre
/usr/local/pcre-8.43# make
/usr/local/pcre-8.43# make install

## apache 설치
/usr/local# cd httpd-2.4.53
/usr/local/httpd-2.4.46# ./configure --prefix=/usr/local/apache2.4 \
--enable-module=so --enable-rewrite --enable-so \
--with-apr=/usr/local/apr \
--with-apr-util=/usr/local/apr-util \
--with-pcre=/usr/local/pcre \
--enable-mods-shared=all
make && make install