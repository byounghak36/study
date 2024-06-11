---
title: mariadb_install
tags:
  - DB
  - mariadb
date: 
Modify_Date: 
reference: 
link:
---


https://victorydntmd.tistory.com/215 (참고)

error #1 패키지 정리 필요
Protected multilib versions: zlib-1.2.7-20.el7_9.x86_64 != zlib-1.2.7-18.el7.i686

yum install yum-utils
-----------------------------------------------------------------------
[ 필수 라이브러리 및 도구 설치 ]
yum install gcc gcc-c++ libtermcap-devel gdbm-devel zlib* libxml* freetype* libpng* libjpeg* iconv flex gmp ncurses-devel libaio perl -y

1) cmake source install
wget https://cmake.org/files/v3.7/cmake-3.7.2.tar.Z
mv cmake-3.7.2.tar.Z cmake-3.7.2.tar.gz
tar zxvf cmake-3.7.2.tar.gz
cd cmake-3.7.2
./bootstrap --prefix=/usr/bin/cmake
make && make install
   
2) 명령어 설정
   # vi /etc/profile
     여기에 없으면 PATH가 없으면
   # vi /root/.bash_profile
     PATH=$PATH:$HOME/bin:/usr/local/apache/bin:/usr/bin/cmake/bin:   //추가
   # source vi /root/.bash_profile
   
3) 설치 확인
   # cmake --version

-----------------------------------------------------------------------
yum install openssl-devel libcurl-devel bison bison-devel boost boost-devel snappy-devel zstd

[참고] https://velog.io/@leliko/Maria-DB-%EC%86%8C%EC%8A%A4-%EC%BB%B4%ED%8C%8C%EC%9D%BC-%EC%84%A4%EC%B9%98CentOS-7
[MariaDB 계정 및 그룹 생성]
(범용성을 위해 MySQL 계정,그룹으로 생성해준다.)
groupadd -g 400 mysql
useradd -u400 -g400 -d /usr/local/mysql -s /bin/false mysql
 
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_ARIA_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_FEDERATEDX_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
-DWITH_XTRADB_STORAGE_ENGINE=1 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DSYSCONFDIR=/etc \
-DWITH_SSL=/usr/local/ssl \
-DMYSQL_TCP_PORT=3306 
-----------------
-DCMAKE_INSTALL_PREFIX: Mariadb가 설치될 경로를 지정합니다. 여기서는 /usr/local/mysql 경로에 설치됩니다.
-DMYSQL_DATADIR: 데이터 디렉토리의 경로를 설정합니다. 여기서는 /usr/local/mysql/data 경로에 데이터가 저장됩니다.
-DDEFAULT_CHARSET: 기본 캐릭터셋을 설정합니다. 여기서는 UTF-8이 기본 캐릭터셋으로 설정됩니다.
-DDEFAULT_COLLATION: 기본 콜레이션을 설정합니다. 여기서는 UTF-8 일반 콜레이션이 기본값으로 설정됩니다.
-DWITH_EXTRA_CHARSETS: 추가 캐릭터셋을 사용할 수 있도록 설정합니다. 여기서는 모든 캐릭터셋이 사용 가능합니다.
-DENABLED_LOCAL_INFILE: 로컬 파일 로딩을 활성화합니다. 이 옵션을 사용하면 클라이언트가 로컬 파일 시스템에서 데이터를 가져올 수 있습니다.
-DWITH_INNOBASE_STORAGE_ENGINE: InnoDB 스토리지 엔진을 사용할 수 있도록 설정합니다. InnoDB는 ACID 호환성과 높은 성능을 가진 스토리지 엔진입니다.
-DWITH_ARCHIVE_STORAGE_ENGINE: Archive 스토리지 엔진을 사용할 수 있도록 설정합니다. Archive 스토리지 엔진은 데이터를 압축하여 저장하므로 디스크 공간을 절약할 수 있습니다.
-DWITH_ARIA_STORAGE_ENGINE: Aria 스토리지 엔진을 사용할 수 있도록 설정합니다. Aria 스토리지 엔진은 트랜잭션 기능이 없지만, 메모리 내 테이블 및 디스크 테이블을 지원합니다.
-DWITH_BLACKHOLE_STORAGE_ENGINE: Blackhole 스토리지 엔진을 사용할 수 있도록 설정합니다. Blackhole 스토리지 엔진은 데이터를 버리고 쿼리를 무시합니다. 주로 로그 캡처에 사용됩니다.
-DWITH_FEDERATEDX_STORAGE_ENGINE: FederatedX 스토리지 엔진을 사용할 수 있도록 설정합니다. FederatedX 스토리지 엔진은 분산 데이터 소스에 대한 쿼리를 실행할 수 있습니다.
-DWITH_PARTITION_STORAGE_ENGINE: 파티션 스토리지 엔진을 사용할 수 있도록 설정합니다. 파티션 스토리지 엔진은 대용량 데이터를 처리할 때 유용합니다.
-DWITH_PERFSCHEMA_STORAGE_ENGINE: Performance Schema 스토리지 엔진을 사용할 수 있도록 설정합니다. Performance Schema는 데이터베이스
-DMYSQL_UNIX_ADDR: MySQL 소켓 파일의 경로를 지정합니다. 여기서는 /tmp/mysql.sock에 소켓 파일이 생성됩니다.
-DSYSCONFDIR: MySQL 설정 파일이 저장될 경로를 지정합니다. 여기서는 /etc 경로에 설정 파일이 저장됩니다.
-DWITH_SSL: SSL 암호화를 사용할 수 있도록 설정합니다. SSL 암호화를 사용하면 데이터 전송 중 보안성을 높일 수 있습니다. 여기서는 /usr/local/ssl 경로에 SSL 라이브러리가 설치되어 있다고 가정합니다.
-DMYSQL_TCP_PORT: MySQL TCP/IP 포트 번호를 지정합니다. 여기서는 3306번 포트를 사용합니다.
------------------

# option 설명

```
#-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
#= mysql을 설치할 기본 경로 지정
#-DMYSQL_DATADIR=/usr/local/mysql/data \
#= MySQL 데이터 디렉토리 위치 지정
#-DMYSQL_UNIX_ADDR=/usr/local/mysql/tmp/socket/mysql.socket \
#= 기본은 /tmp/mysql.sock 이며, Unix socket 파일 경로는 서버에 소켓 연결할 때 지정된다.
#-DINSTALL_SYSCONFDIR=/etc \
#= my.cnf 옵션 파일 디렉토리 위치 지정
#-DINSTALL_SYSCONF2DIR=/etc/my.cnf.d \
#= my.cnf 옵션 파일 디렉토리 위치 지정
#-DMYSQL_TCP_PORT=3306 \
#= TCP/IP 연결시 사용하는 포트 번호 지정. 기본 3306.
#-DDEFAULT_CHARSET=utf8 \
#= 언어셋을 utf8로 지정
#-DDEFAULT_COLLATION=utf8_general_ci \
#= 콜레이션을 utf8_general_ci 로 설정.
#-DWITH_EXTRA_CHARSETS=all \
#= all이 기본이며, 모든 문자열 셋을 포함한다는 의미
#-DENABLED_LOCAL_INFILE=1 \
#= MySQL 문법 중에 load data infile이라는 것이 있다. txt 파일 등을 mysql data로 가져오는 문법이라 편리하지만 보안상의 문제가 동시에 발생하기 때문에 1로 지정해준다.
#서버에서 스토리지 엔진을 정적으로 컴파일한다면, 아래와 같은 설정들을 할 수 있다.
#-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
#-DWITH_INNOBASE_STORAGE_ENGINE=1 \
#-DWITH_ARIA_STORAGE_ENGINE=1 \
#-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
#-DWITH_FEDERATEDX_STORAGE_ENGINE=1 \
#-DWITH_PARTITION_STORAGE_ENGINE=1 \
#-DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
#-DWITH_XTRADB_STORAGE_ENGINE=1 \
#-DWITH_MYISAM_STORAGE_ENGINE=1 \

#-DWITH_ZLIB=system \
# system으로 할 경우에 시스템에 설치된 Library를 이용
#-DWITH_READLINE=1 \
#readline 지원여부
#-DWITH_SSL=system \
#MySQL은 SSL 라이브러리를 무조건 사용해야하는데, 특정 옵션(yes, bundled, system)을 정하여 사용한다. #MySQL5.7 에서는 bundled가 기본.

완료 후 
make && make install

vi /usr/lib/systemd/system/mysqld.service

[Unit]
Description=MariaDB Database Server
After=syslog.target
After=network.target

[Service]
KillMode=process
KillSignal=SIGTERM
SendSIGKILL=no

User=maria
Group=maria

PermissionsStartOnly=true
PrivateTmp=true
OOMScoreAdjust=-1000
ExecStart=/usr/local/maria/bin/maria --defaults-file=/etc/my.cnf --plugin-dir=/usr/local/maria/lib/plugin
Restart=always
RestartSec=1
TimeoutSec=300

[Unit]
Description=MariaDB Database Server
After=syslog.target
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/mariadb/bin/mysqld
ExecStop=/usr/local/mariadb/bin/mysqladmin shutdown
User=root
Group=root
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target

> use mysql;
> update user set password=password('변경할_비밀번호') where user='root';
> flush privileges;
> quit
```

[Unit] 섹션은 서비스를 설명하는 부분으로, Description은 서비스에 대한 간단한 설명을 작성합니다. After는 해당 서비스가 실행되기 전에 실행되어야 할 타겟을 지정합니다.

[Service] 섹션은 서비스 실행 관련 정보를 작성하는 부분입니다. Type은 서비스의 타입을 지정합니다. simple은 해당 서비스가 실행 중인 상태를 유지해야 하는 서비스에 사용됩니다. ExecStart은 해당 서비스를 실행하는 명령어를 작성합니다. 이 예시에서는 /usr/local/mariadb/bin/mysqld를 실행하도록 지정했습니다. ExecStop은 서비스가 중지될 때 실행되는 명령어를 지정합니다. 이 예시에서는 /usr/local/mariadb/bin/mysqladmin shutdown을 실행하도록 지정했습니다. User와 Group은 해당 서비스를 실행하는 사용자와 그룹을 지정합니다. LimitNOFILE은 해당 서비스에서 사용할 수 있는 최대 파일 디스크립터 수를 제한합니다.

[Install] 섹션은 해당 서비스가 실행될 레벨을 지정하는 부분입니다. WantedBy는 해당 서비스가 실행될 레벨을 지정합니다. multi-user.target은 사용자 레벨에서 실행되는 서비스에 사용됩니다.

위의 설정을 통해 /usr/local/mariadb/bin/mysqld를 실행하는 MariaDB 서비스가 등록되며, systemctl start mariadb.service 명령어로 서비스를 실행할 수 있습니다.


[Service] 섹션에서 KillMode, KillSignal, SendSIGKILL은 프로세스를 종료할 때 사용하는 설정입니다. KillMode은 process를 지정하여 프로세스를 종료합니다. KillSignal은 프로세스를 종료할 때 사용하는 시그널을 지정합니다. SendSIGKILL은 no를 지정하여 시그널을 보내지 않고 직접 프로세스를 종료합니다.

User와 Group은 해당 서비스를 실행하는 사용자와 그룹을 지정합니다.

LimitNOFILE, LimitNPROC, LimitCORE는 각각 서비스에서 사용할 수 있는 최대 파일 디스크립터 수, 최대 프로세스 수, 최대 코어 파일 사이즈를 제한하는 옵션입니다.

PermissionsStartOnly는 서비스를 실행하기 전에 권한을 확인하는 옵션입니다. PrivateTmp는 해당 서비스에서 사용하는 임시 디렉토리를 설정합니다. OOMScoreAdjust는 Out-Of-Memory killer가 해당 서비스의 프로세스를 종료하기 전에 가중치를 조절하는 옵션입니다.

ExecStart는 해당 서비스를 실행하는 명령어를 작성합니다. 이 예시에서는 /usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --plugin-dir=/usr/local/mysql/lib/plugin를 실행하도록 지정했습니다. Restart와 RestartSec는 서비스가 중지됐을 때 자동으로 재시작하는 옵션입니다. TimeoutSec는 서비스의 제한 시간을 지정합니다.
