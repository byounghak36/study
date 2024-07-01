---
title: Apache,Tomcat_연동
tags: 
date: 2024_07_01
reference: 
link:
---



```shell
libtool: warning: remember to run 'libtool --finish /usr/lib64/httpd/modules'
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/apache-2.0' 나감
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native' 들어감
make[1]: 'all-am'을(를) 위해 할 일이 없습니다.
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native' 나감
target="all"; \
list='common apache-2.0'; \
for i in $list; do \
    echo "Making $target in $i"; \
    if test "$i" != "."; then \
       (cd $i && make $target) || exit 1; \
    fi; \
done;
Making all in common
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/common' 들어감
make[1]: 'all'을(를) 위해 할 일이 없습니다.
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/common' 나감
Making all in apache-2.0
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/apache-2.0' 들어감
../scripts/build/instdso.sh SH_LIBTOOL='/usr/lib64/apr-1/build/libtool --silent' mod_jk.la `pwd`
/usr/lib64/apr-1/build/libtool --silent --mode=install cp mod_jk.la /home/rocky/tomcat-connectors-1.2.49-src/native/apache-2.0/
libtool: warning: remember to run 'libtool --finish /usr/lib64/httpd/modules'
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/apache-2.0' 나감
Making install in common
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/common' 들어감
make[1]: 'install'을(를) 위해 할 일이 없습니다.
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/common' 나감
Making install in apache-2.0
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/apache-2.0' 들어감

Installing files to Apache Modules Directory...
/bin/apxs -i mod_jk.la
/usr/lib64/httpd/build/instdso.sh SH_LIBTOOL='/usr/lib64/apr-1/build/libtool' mod_jk.la /usr/lib64/httpd/modules
/usr/lib64/apr-1/build/libtool --mode=install install mod_jk.la /usr/lib64/httpd/modules/
libtool: install: install .libs/mod_jk.so /usr/lib64/httpd/modules/mod_jk.so
install: cannot create regular file '/usr/lib64/httpd/modules/mod_jk.so': Permission denied
apxs:Error: Command failed with rc=65536
.
make[1]: *** [Makefile:93: install_dynamic] 오류 1
make[1]: 디렉터리 '/home/rocky/tomcat-connectors-1.2.49-src/native/apache-2.0' 나감
make: *** [Makefile:469: install-recursive] 오류 1
```