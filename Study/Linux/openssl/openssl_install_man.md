---
title: openssl_install_man
tags:
  - openssl
  - linux
date: 
Modify_Date: 
reference: 
link:
---


# OpenSSL 이란?
OpenSSL은 네트워크를 통한 데이터 통신에 쓰이는 프로토콜인 SSL/TLS의 오픈 소스 구현판이다. C 언어로 작성되어 있는 중심 라이브러리 안에는, 기본적인 암호화 기능 및 여러 유틸리티 함수들이 구현되어 있다.

---

## 소스 설치 시 주의 사항
- openssl을 소스 컴파일로 설치한 이후, 해당 openssl의 라이브러리를 이용하여 Source 설치한 프로그램이 있다면 해당 프로그램은 openssl 라이브러러에 의존성을 가지게 된다. 한마디로 설치한 openssl이 없으면 정상적으로 구동되지 않는다는 의미이다.
- openssl을 재컴파일(재설치)하게 되면 의존성 문제가 발생하여 이후에 설치한 프로그램들이 정상적으로 동작하지 않게 된다. 이럴 경우 openssl을 이용하여 설치한 프로그램들도 재컴파일 해주어야 한다.
- 예를 들어 openssl 1.0.2s를 소스 설치한 이후, httpd 2.4.39를 설치했다고 가정해보자. openssl 취약점때문에 최신 버전(1.0.2u)으로 재컴파일을 하게 된다면 httpd 2.4.39는 정상 동작을 하지 않을 수 있다. httpd 2.4.39를 설치할 때 1.0.2s의 소스 코드(정확히는 라이브러리)를 사용하여 설치했는데, 1.0.2u에서 소스 코드 상의 변경점이 생기면 httpd 2.4.39에 반영이 되지 않는다.

---

## 1. 컴파일에 필요한 패키지 다운로드

```
[root@localhost]# apt-get install build-essential // ubuntu
[root@localhost]# yum groupinstall 'development-tools' // Centos
```
## 2. 소스 파일 다운로드
   
```
[root@localhost src]# wget https://www.openssl.org/source/openssl-1.1.1t.tar.gz
[root@localhost src]# tar zxvf openssl-1.0.2s.tar.gz
[root@localhost src]# cd openssl-1.0.2s
```

## 3. 컴파일 옵션 수정

```
[root@localhost openssl-1.1.1t]# ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl
[root@localhost openssl-1.1.1t]# make
[root@localhost openssl-1.1.1t]# make install
[root@localhost ~]# /usr/local/openssl/bin/openssl version
/usr/local/openssl/bin/openssl: error while loading shared libraries: libssl.so.1.1: cannot open shared object file: No such file or director
```

- 설치 후 직접 bin 파일을 실행시켜보면, 에러 발생한다. 이는 openssl 실행 시 필요한 공유 라이브러리가 위치한 경로(/usr/local/openssl/lib)를 OS가 인식하지 못하여 발생하는 것이며, 아래와 같이 라이브러리 경로를 설정해주면 된다.

## 4. 동적 링크 생성

```
[root@localhost ~]# vi /etc/ld.so.conf
include ld.so.conf.d/*.conf
/usr/local/openssl/lib  -> 추가 후 저장	
[root@localhost ~]# ldconfig 
[root@localhost ~]# /usr/local/openssl/bin/openssl 
OpenSSL> version
OpenSSL 1.0.2s  20 Nov 2018
[root@localhost ~]# /usr/local/openssl/bin/openssl version
OpenSSL 1.1.1d  10 Sep 2019
```

## 5. 심볼릭 링크 생성 (기존 설치된 파일이 있다면 지워야함)

```
ln -s /usr/local/ssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -s /usr/local/ssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
```

끝