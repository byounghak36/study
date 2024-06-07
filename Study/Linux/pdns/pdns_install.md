---
title: pdns_install
tags:
  - pdns
  - dns
date: 
Modify_Date: 
reference: 
link:
---

# PDNS 설치 및 설정 메뉴얼

본 메뉴얼은 기존에 아래와 같이 패키지가 설치가 되어있는 환경에서 작성되었음.

- **httpd**
    + Version : 2.4.56
    + Install Dir : /usr/local/apache
- **php**
    + version : 8.2.1
    + Install Dir : /usr/local/php-8.2.1
    + Source Dir : /usr/local/src/php-8.2.1
    + install option & install plugin
        * install option
            ```
            ./configure \
            --prefix=/usr/local/php-8.2.1 \
            --with-apxs2=/usr/local/apache/bin/apxs \
            --with-config-file-path=/usr/local/apache/conf \
            --with-pdo-mysql=/usr/local/mysql \
            --with-openssl \
            --with-openssl-dir=/usr/local/ssl \
            --enable-zts
            ```
            - '--with-pdo-mysql' 옵션은 필수
        * install plugin
            ```
            [root@kimbh0132-197619 no-debug-zts-20220829]# ls
            gettext.so  intl.so  opcache.so

            ```
            - opecache는 '--enable-zts' 옵션을 통해서 설치되었음
            - 'intl.so', 'gettext.so'는 src 디렉토리에서 phpize를 통해 컴파일 설치하였지만
            인스톨시 각각 '--enable-intl', '--with-gettext=[dir]' 옵션을 통해 설치 가능함 
            - MDB2 모듈도 설치가 필요함 아래와 같이 설치 진행하였음(pear 설치는 '/usr/local/src/php-8.2.1/pear/'' 에서 확인)
            ```
            [root@localhost inc]# cd /usr/local/php/bin/
            [root@localhost inc]# ./pear install MDB2
            [root@localhost inc]# ./pear install MDB2_Driver_mysql
            [root@localhost inc]# /sbin/ldconfig
            [root@localhost inc]# /usr/local/apache2/bin/httpd -t
            [root@localhost inc]# /usr/local/apache2/bin/apachectl restart
            ```
- **mariadb**
    + Version : mariadb-10.6.12
    + Install Dir : : /usr/local/maria
---

## 설치 방법

### 1. pdns와 pnds-backend-mysql 설치
```
yum install pdns pdns-backend-mysql
```

- pdns-background-msyql 은 pdns 에서 mysql에 접속하기위한 필수 패키지임으로 설치 필요

### 2. Powerdns 용 계정 생성
```
MariaDB [(none)]> create database pdns;
MariaDB [(none)]> grant all privileges on pdns.* to 'pdns'@'localhost' identified by 'qwe1212';
MariaDB [(none)]> grant all privileges on pdns.* to 'pdns'@'127.0.0.1' identified by 'qwe1212'
MariaDB [(none)]> flush privileges;
```
- pdns-backend-mysql을 통해 접속 할 수 있도록 수정
```
echo ```
launch=gmysql
gmysql-host=127.0.0.1
gmysql-user=pdns
gmysql-password=qwe1212
gmysql-dbname=pdns
``` >> /etc/pdns/pdns.conf
```

### 3. pdns start
```
systecmctl start pdns
```
    
나의경우 처음에 gmysql-host를 localhost로 해도 될것이라고 생각해서 진행하였음 그러니 아래와같은 에러 발생 및 구동하지 않았음
```
pdns_server: gmysql Connection failed: Unable to connect to database: Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (13)
```
'/var/lib/mysql/mysql.sock'로 심볼릭 링크도 생성하였지만 해결되지않아, 소켓을 사용하지않고 TCP/IP로 접속하도록 127.0.0.1로 호스트변경, 이후 정상작동함

### 4. PowerAdmin 필요 플러그인 설치
Poweradmin 을 열기위해선 gettext, intl, MDB2, pdo_mysql 이 필요하다 따라서 플러그인 설치 진행
- gettext
```
[root@localhost]# cd /usr/local/src/php-8.2.1/ext/gettext
[root@localhost]# phpize
Configuring for:
PHP Api Version:         20220829
Zend Module Api No:      20220829
Zend Extension Api No:   420220829
[root@localhost]# cd /usr/local/src/php-8.2.1/ext/gettext
[root@localhost]# ./configure --with-php-config=/usr/local/php-8.2.1/bin/php-config
[root@localhost]# make && make install
Installing shared extensions:     /usr/local/php-8.2.1/lib/php/extensions/no-debug-zts-20220829/
[root@localhost]# vi /usr/local/apache/conf/php.ini
~
[gettext]
extension=/usr/local/php-8.2.1/lib/php/extensions/no-debug-zts-20220829/gettext.so
~
[root@localhost]# systecmctl restart apache
[root@localhost]# php -m | grep gettext
gettext
```
- intl
```
[root@localhost]# cd /usr/local/src/php-8.2.1/ext/intl
[root@localhost]# phpize
[root@localhost]# sudo yum install libicu-devel #필요 라이브러리 설치
[root@localhost]# ./configure --with-php-config=/usr/local/php-8.2.1/bin/php-config
[root@localhost]# make && make install
```
- MDB2
```
[root@localhost inc]# cd /usr/local/php/bin/
[root@localhost inc]# ./pear install MDB2
[root@localhost inc]# ./pear install MDB2_Driver_mysql
[root@localhost inc]# /sbin/ldconfig
[root@localhost inc]# /usr/local/apache2/bin/httpd -t
[root@localhost inc]# /usr/local/apache2/bin/apachectl restart
```
- pdo_msyql
php 빌드시 옵션 추가하여서 설치 완료


### 5 Poweradmin 계정 생성및 설정
poweradmin 설정은 이미지가 많은 관계로 링크로 대체함
https://susoterran.github.io/other/poweradmin_install/

### 6 PowerDNS의 주/보조 서버 간 동기화
- 주 서버에서의 설정
allow-axfr-ips와 master의 2가지 옵션을 설정합니다.
```
[root@localhost ~]# vi /etc/pdns/pdns.conf 
~
launch=gmysql
gmysql-host=127.0.0.1
gmysql-user=pdns
gmysql-password=qwe1212
gmysql-dbname=pdns
allow-axfr-ips=115.68.249.233/32 #보조서버 IP
master=yes        #추가
~

[root@localhost ~]# systemctl restart pdns
```
- 보조 서버에서의 설정
```
[root@localhost ~]# vi /etc/pdns/pdns.conf 
~
launch=gmysql
gmysql-host=127.0.0.1
gmysql-user=pdns
gmysql-password=qwe1212                                 
gmysql-dbname=pdns
master=no   #추가
slave=yes   #추가
slave-cycle-interval=60   #추가
~

[root@localhost ~]# systemctl restart pdns
```
- 보조dns 서버 supermaster 설정
supermasters 설정은 보조 서버의 DB에서 진행한다.
```
[root@localhost ~]# /usr/local/mysql/bin/mysql -u root -p
mysql> use pdns;
mysql> INSERT INTO supermasters (ip, nameserver, account) VALUES ('115.68.249.230','ns1.kimbh.xyz','admin');
MariaDB [pdns]> select * from supermasters;
+----------------+---------------+---------+
| ip             | nameserver    | account |
+----------------+---------------+---------+
| 115.68.249.230 | ns2.kimbh.xyz | admin   |
+----------------+---------------+---------+
```
보조dns 서버의 동기화 된 로그
slave log
```
Mar 17 15:12:26 kimbh0132-197840 pdns_server: Unable to retrieve SOA for kimbh.xyz, this was the first time. NOTE: For every subsequent failed SOA check the domain will be suspended from freshness checks for 'num-errors x 60 seconds', with a maximum of 3600 seconds. Skipping SOA checks until 1679033606
Mar 17 15:13:26 kimbh0132-197840 pdns_server: 1 slave domain needs checking, 0 queued for AXFR
Mar 17 15:13:26 kimbh0132-197840 pdns_server: Received serial number updates for 1 zone, had 0 timeouts
Mar 17 15:13:26 kimbh0132-197840 pdns_server: Domain 'kimbh.xyz' is stale, master serial 2023031721, our serial 0
Mar 17 15:13:26 kimbh0132-197840 pdns_server: Initiating transfer of 'kimbh.xyz' from remote '115.68.249.230'
Mar 17 15:13:26 kimbh0132-197840 pdns_server: Starting AXFR of 'kimbh.xyz' from remote 115.68.249.230:53
Mar 17 15:13:26 kimbh0132-197840 pdns_server: AXFR started for 'kimbh.xyz'
Mar 17 15:13:26 kimbh0132-197840 pdns_server: AXFR of 'kimbh.xyz' from remote 115.68.249.230:53 done
Mar 17 15:13:26 kimbh0132-197840 pdns_server: Backend transaction started for 'kimbh.xyz' storage
Mar 17 15:13:26 kimbh0132-197840 pdns_server: AXFR done for 'kimbh.xyz', zone committed with serial number 2023031721
Mar 17 15:14:26 kimbh0132-197840 pdns_server: No new unfresh slave domains, 0 queued for AXFR already, 0 in progress
```
- record 등록한 사진
![사진1](master_serv_record.png)

- whois
```
kimbh@kimbh:~$ whois kimbh.xyz
Domain Name: KIMBH.XYZ
Registry Domain ID: D350316264-CNIC
Registrar WHOIS Server: whois.gabia.com
Registrar URL:
Updated Date: 2023-03-17T04:51:12.0Z
Creation Date: 2023-02-23T01:24:37.0Z
Registry Expiry Date: 2024-02-23T23:59:59.0Z
Registrar: Gabia, Inc.
Registrar IANA ID: 244
Domain Status: serverTransferProhibited https://icann.org/epp#serverTransferProhibited
Domain Status: clientTransferProhibited https://icann.org/epp#clientTransferProhibited
Registrant Organization:
Registrant State/Province:
Registrant Country: KR
Registrant Email: Please query the RDDS service of the Registrar of Record identified in this output for information on how to contact the Registrant, Admin, or Tech contact of the queried domain name.
Admin Email: Please query the RDDS service of the Registrar of Record identified in this output for information on how to contact the Registrant, Admin, or Tech contact of the queried domain name.
Tech Email: Please query the RDDS service of the Registrar of Record identified in this output for information on how to contact the Registrant, Admin, or Tech contact of the queried domain name.
Name Server: NS1.KIMBH.XYZ
Name Server: NS2.KIMBH.XYZ
DNSSEC: unsigned
Billing Email: Please query the RDDS service of the Registrar of Record identified in this output for information on how to contact the Registrant, Admin, or Tech contact of the queried domain name.
Registrar Abuse Contact Email: dispute@gabia.com
Registrar Abuse Contact Phone:
URL of the ICANN Whois Inaccuracy Complaint Form: https://www.icann.org/wicf/
>>> Last update of WHOIS database: 2023-03-17T07:26:47.0Z <<<

For more information on Whois status codes, please visit https://icann.org/epp

>>> IMPORTANT INFORMATION ABOUT THE DEPLOYMENT OF RDAP: please visit
https://www.centralnic.com/support/rdap <<<

The Whois and RDAP services are provided by CentralNic, and contain
information pertaining to Internet domain names registered by our
our customers. By using this service you are agreeing (1) not to use any
information presented here for any purpose other than determining
ownership of domain names, (2) not to store or reproduce this data in
any way, (3) not to use any high-volume, automated, electronic processes
to obtain data from this service. Abuse of this service is monitored and
actions in contravention of these terms will result in being permanently
blacklisted. All data is (c) CentralNic Ltd (https://www.centralnic.com)

Access to the Whois and RDAP services is rate limited. For more
information, visit https://registrar-console.centralnic.com/pub/whois_guidance.

```

- nslookup
```
kimbh@kimbh:~$ nslookup kimbh.xyz
Server:     127.0.0.53
Address:    127.0.0.53#53

Non-authoritative answer:
Name:   kimbh.xyz
Address: 115.68.248.198
##################################
kimbh@kimbh:~$ nslookup -type=ns kimbh.xyz
Server:     127.0.0.53
Address:    127.0.0.53#53

Non-authoritative answer:
kimbh.xyz   nameserver = ns2.kimbh.xyz.
kimbh.xyz   nameserver = ns1.kimbh.xyz.

Authoritative answers can be found from:
##################################
kimbh@kimbh:~$ nslookup -type=ns ns1.kimbh.xyz
Server:     127.0.0.53
Address:    127.0.0.53#53

Non-authoritative answer:
*** Can't find ns1.kimbh.xyz: No answer

Authoritative answers can be found from:
kimbh.xyz
    origin = ns1.kimbh.xyz
    mail addr = admin.kimbh.xyz
    serial = 2023031727
    refresh = 28800
    retry = 7200
    expire = 604800
    minimum = 86400
##################################
kimbh@kimbh:~$ nslookup -type=ns ns2.kimbh.xyz
Server:     127.0.0.53
Address:    127.0.0.53#53

Non-authoritative answer:
*** Can't find ns2.kimbh.xyz: No answer

Authoritative answers can be found from:
kimbh.xyz
    origin = ns1.kimbh.xyz
    mail addr = admin.kimbh.xyz
    serial = 2023031727
    refresh = 28800
    retry = 7200
    expire = 604800
    minimum = 86400
##################################
kimbh@kimbh:~$ nslookup ns1.kimbh.xyz
Server:     127.0.0.53
Address:    127.0.0.53#53

Non-authoritative answer:
Name:   ns1.kimbh.xyz
Address: 115.68.249.230
##################################
kimbh@kimbh:~$ nslookup ns2.kimbh.xyz
Server:     127.0.0.53
Address:    127.0.0.53#53

Non-authoritative answer:
Name:   ns2.kimbh.xyz
Address: 115.68.249.233

```

- dig
```
kimbh@kimbh:~$ dig kimbh.xyz a @ns1.kimbh.xyz

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> kimbh.xyz a @ns1.kimbh.xyz
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 53101
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1680
;; QUESTION SECTION:
;kimbh.xyz.         IN  A

;; ANSWER SECTION:
kimbh.xyz.      86400   IN  A   115.68.248.198

;; Query time: 4 msec
;; SERVER: 115.68.249.230#53(ns1.kimbh.xyz) (UDP)
;; WHEN: Fri Mar 17 16:32:18 KST 2023
;; MSG SIZE  rcvd: 54

kimbh@kimbh:~$ dig kimbh.xyz a @ns2.kimbh.xyz

; <<>> DiG 9.18.1-1ubuntu1.3-Ubuntu <<>> kimbh.xyz a @ns2.kimbh.xyz
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16982
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1680
;; QUESTION SECTION:
;kimbh.xyz.         IN  A

;; ANSWER SECTION:
kimbh.xyz.      86400   IN  A   115.68.248.198

;; Query time: 8 msec
;; SERVER: 115.68.249.233#53(ns2.kimbh.xyz) (UDP)
;; WHEN: Fri Mar 17 16:32:30 KST 2023
;; MSG SIZE  rcvd: 54

```
끝
