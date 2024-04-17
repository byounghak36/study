1. 버전확인
[root@content173-193883 local]# /usr/local/bind/sbin/named -v
BIND 9.18.12 (Extended Support Version) <id:99783f9>

2. 기본 유저 등록 및 환경설정 작업 ( 기본 /usr/sbin/에 있는 named명령어를 교체해 준다 )
[root@content173-193883 local]# useradd -u 25 -r -d /var/named -s /bin/false named
(UID 25,시스템 계정으로 생성, 디렉토리 /var/named, 홈디렉토리 생성하지 않음, 기본쉘 없음)
[root@content173-193883 var]# mkdir -p /var/named/dynamic
[root@content173-193883 var]# mkdir -p /var/named/log
[root@content173-193883 var]# ln -s /usr/local/bind/sbin/named* /usr/sbin
[root@content173-193883 var]# ln -s /usr/local/bind/sbin/rndc /usr/sbin
[root@content173-193883 var]# chown -R named:named /var/named/