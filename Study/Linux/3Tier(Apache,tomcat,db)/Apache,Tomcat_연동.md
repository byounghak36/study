---
title: Apache,Tomcat_연동
tags: 
date: 2024_07_01
reference: 
link:
---
### Apache, Tomcat 연동하기

아파치와 톰캣을 연동하는 방법은 mod_jk, mod_proxy, mod_proxy_ajp를 이용한 방법이 있다.  
이번에는 연동 방법 중 가장 많이 사용 되는 mod_jk로 Apache와 Tomcat을 연동 해보도록 하겠다.

#### mod_jk 란?

Apache와 Tomcat을 연동하기 위한 모듈이다. AJP 프로토콜을 이용하여 아파치로 들어온 요청을 톰캣에 전달하여 처리한다. 아파치로 들어온 요청을 톰캣으로 전달 할때 AJP 포트 (기본 8009)를 사용하며 필요에 의한 포트 변경도 가능하다.

#### 1.Apache 설치
Apache 및 mod_jk 컴파일 설치를 위해 몇 가지 추가 패키지를 설치 해준다.
```shell
yum install -y httpd autoconf libtool httpd-devel
```

#### 2. mod_jk 설치
mod_jk 설치를 위해 mod_jk를 다운 받는다. 톰캣 사이트([http://tomcat.apache.org/download-connectors.cgi](http://tomcat.apache.org/download-connectors.cgi))에 접속하여 리눅스용 파일을 다운로드 한다.
```shell
wget https://downloads.apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz
```

다운받은 파일을 압축 해제 한다.

```shell
tar -xvzf tomcat-connectors-1.2.48-src.tar.gz
ls
tomcat-connectors-1.2.48-src tomcat-connectors-1.2.48-src.tar.gz
```
#### mod_jk 컴파일 설치

압축 해제 후 tomcat-connectors-1.2.48-src

```null

# cd tomcat-connectors-1.2.48-src/native
# ./buildconf.sh
# ./configure --with-apxs=/bin/apxs
# make 
# make install
```



---
에러 #1
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