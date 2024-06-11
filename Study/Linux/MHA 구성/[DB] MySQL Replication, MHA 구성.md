---
title: "[DB] MySQL Replication, MHA 구성"
tags:
  - DB
  - replication
date: 
Modify_Date: 
reference: 
link:
---
![[Pasted image 20240515153935.png]]
## DB Replication 이란?
DB Replication(복제)는 2대이상의 DBMS를 사용하여 데이터를 저장하는 방법이며 Master/Slave 구조로 사용됩니다.
각 노드별 역할은 다음과 같습니다.

-  Master DBMS
   - 웹서버로 부터 데이터 등록/수정/삭제 요청시 바이너리로그(Binarylog)를 생성하여 Slave 서버로 전달하게 됩니다.
   - 웹서버로 부터 요청한 데이터 등록/수정/삭제(Create/Update/Delete) 기능을 하는 DBMS로 많이 사용됩니다.
- Slave DBMS
   - Master DBMS로 부터 전달받은 바이너리로그(Binarylog)를 데이터로 반영하게 됩니다.
   - 웹서버로 부터 요청을 통해 데이터를 불러오는(Read) DBMS로 많이 사용됩니다.

위와같이 Master 노드와 Slave 노드를 분할하면서 하나의 노드에 장애가 발생하더라도 다른 노드가 대신 작업을 수행할 수 있도록 동기화를 진행하고, 역할을 분배함으로써 서비스의 가용성을 높일 수 있습니다.

---
### Replication 동작 방식
DB Replication 은 보통 위의 구성으로 이루어집니다. 해당 순서를 자세히 설명하면 아래와 같습니다.

1. 마스터 노드에 commit이 발생합니다.
   - 마스터 노드에서 DML(Data Manipulation Language) 작업이 수행되면, 해당 작업의 결과가 데이터베이스에 반영됩니다.

2. 마스터 노드의 binlog 에 데이터 변경 사항이 기록됩니다.
   - binlog에 마스터 노드에서 발생하는 모든 데이터 변경 사항이 기록됩니다.
   - binlog에는 데이터 변경 사항의 유형, 대상 테이블, 변경된 데이터 등의 정보가 기록됩니다.   

3. 마스터 노드의 IO 스레드가 binlog를 읽어 Relay Log에 저장합니다.
    - 마스터 노드의 IO 스레드에서 binlog를 읽어 Relay Log에 저장합니다.
    - Relay Log는 마스터 노드에서 발생한 데이터 변경 사항을 기록하는 파일입니다.

4. 슬레이브 노드의 SQL 스레드가 Relay Log를 읽어 데이터베이스에 적용합니다.
    - 슬레이브 노드의 SQL 스레드는 Relay Log를 읽어 데이터베이스에 적용합니다. 이때, 슬레이브 노드의 데이터베이스는 마스터 노드의 데이터베이스와 동기화됩니다.

기본적으로 master node 의 binlog를 전송, slave node 에서 binlog의 commit을 수행하는것으로 replication 이 진행되지만, 이는 동기식/반동기식/비동기식 중 어떤 동기화 방식을 채택하냐에 따라 조금씩 차이를 가질 수 있습니다.

---
## MHA 란?

Master DB가 장애가 발생하여 서비스가 불가능할경우, 자동으로 Slave DB를 승격하여 서비스 다운타임을 최소화하는 Perl 기반 Auto Failover 오픈 소스 입니다.

MySQL DB Replication만으로 Replication 을 구성했을경우 관리자가 직접 Master DB 변경작업을 실행하여야 합니다. 또한 다중 노드를 구성하여 운영중일경우 어떤것을 Master Node 로 승격하는것이 좋은 선택일지 고민해야할지도 모릅니다.

MHA의 경우 Master Node 에서 Fail이 발생할경우, 수초 내에 보유중인 Slave Node 중 가장 최근에 복제된 Node를 Master로 승격 후 서비스를 지속하여 서비스 다운타임을 최소화합니다.

---
## MHA 구성

**System Enviroment**

| node        | version                    | ip            | vip           |
|-------------|----------------------------|---------------|---------------|
| mha-manager | ubuntu 22.04, mysql-8.0.35 | 192.168.1.162 | 192.168.10.9  |
| db-node-01  | ubuntu 22.04, mysql-8.0.35 | 192.168.1.38  | 192.168.10.10 |
| db-node-02  | ubuntu 22.04, mysql-8.0.35 | 192.168.1.18  | 192.168.10.10 |
| db-node-03  | ubuntu 22.04, mysql-8.0.35 | 192.168.1.254 | 192.168.10.10 |

---
### 필요 패키지 설치및 my.cnf 설정
모든 노드에서 apt 설치
```bash
$ apt install  -y mysql-server mysql-clients
```
이후 manager 서버를 제외한 노드들은 /etc/mysql/my.cnf 에 아래 내용을 추가한다
```bash
[mysqld]
user            = mysql
bind-address            = 0.0.0.0
mysqlx-bind-address     = 127.0.0.1
myisam-recover-options  = BACKUP
# 각노드마다 server-id 를 다르게 설정한다, node1은 1, node2는 2 ...
server-id=1
log_error=/var/log/mysql/error.log
# binlog를 통하여 이중화를 함으로, 해당 디렉토리 위치를 잘 인지하고 있어야함
log-bin=/var/log/mysql/binlog
sync_binlog=1
binlog_cache_size=2M
max_binlog_size=512M
expire_logs_days=7
log-bin-trust-function-creators=1
# 각 DB의 호스트네임으로 추후 replication시에 show slave hosts 에서 정보로 활용
report-host=db-node-01
relay-log=/var/log/msyql/relay_log
relay-log-index=/va/log/mysql/relay_log.index
relay_log_purge=off
binlog_expire_logs_seconds=604800
log_replica_updates=on

$ systemctl restart mysql.service
```
정상적으로 적용 되었을경우 별다른 메시지없이 restart가 수행된다.

간혹 아래와 같은 에러가 발생하는데(/var/log/mysql/error.log) binlog.index파일의 권한이 잘못 설정되어 있을경우 발생한다
```
# /var/log/mysql/error.log 의 일부
2023-11-28T01:43:40.127485Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.35-0ubuntu0.22.04.1) starting as process 3401
mysqld: File '/var/log/mysql/binlog.index' not found (OS errno 13 - Permission denied)
```
해결방법
```bash
# 혹여나 파일이 없다면 파일을 생성하고 권한을 부여해야한다.
# touch /var/log/mysql/binlog.index
$ chown mysql:mysql /var/log/mysql/binlog.index
$ systemctl restat mysql.service
```
---
### Master & Slave 설정
Replication 용 계정 생성 (master 및 slave 노드)
```sql
mysql> create user 'repl_user'@'%' identified by 'qwe1212';
mysql> grant replication slave on *.* to 'repl_user'@'%';
mysql> flush privileges;
```
master node 에서 binlog 파일과 position 조회
```sql
mysql> show master status;
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000005 |      621 |              |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```
file 명과 Position 을 기억해둔뒤 slave 노드에서 master를 바라보도록 설정
```sql
mysql> CHANGE MASTER TO MASTER_HOST='192.168.1.38', MASTER_USER='repl_user',
    -> MASTER_PASSWORD='qwe1212',
    -> MASTER_LOG_FILE='binlog.000005',
    -> MASTER_LOG_POS=621;
Query OK, 0 rows affected, 8 warnings (0.51 sec)
```
이후 show slave status 를 통해 replication 구성이 되었는지 확인
```sql
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.168.1.38
                  Master_User: repl_user
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000005
          Read_Master_Log_Pos: 621
               Relay_Log_File: relay_log.000002
                Relay_Log_Pos: 323
        Relay_Master_Log_File: binlog.000005
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 621
              Relay_Log_Space: 527
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: ca370645-8d89-11ee-94da-fa163e71941e
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
       Master_public_key_path:
        Get_master_public_key: 0
            Network_Namespace:
1 row in set, 1 warning (0.00 sec)

ERROR:
No query specified
```
master_log_file, read_master_log_pos 이 지정한 파일로 설정이 되어있다면 정상이며
```sql
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```
위 두부분이 yes로 되어있다면 정상적인 모습이다. 혹여나 No라고 떠있다면 ``Last_IO_Error:`` 란과, error.log 를 통해서 트러블 슈팅을 해보자. 필자는 아래와 같은 에러가 발생했었다.

```
Last_IO_Error: Fatal error: The replica I/O thread stops because source and replica have equal MySQL server ids; these ids must be different for replication to work (or the --replicate-same-server-id option must be used on replica but this does not always make sense; please check the manual before using it).
```
확인해보니 server-id 가 동일하게 설정되어있어서 확인후 변경하였다.
```sql
mysql> show variables like 'server_id';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| server_id     | 1     |
+---------------+-------+
1 row in set (0.00 sec)

mysql> SET GLOBAL server_id = 2;
mysql> flush privilges;
```
---
### 각 노드 vip 설정
- master node
```bash
$ echo "ifconfig ens3:0 192.168.10.9 netmask 255.255.255.0 up" >> ~/.bashrc
$ source ~/.bashrc
```

- slave node 1, 2, 3
```bash
$ echo "ifconfig ens3:0 192.168.10.10 netmask 255.255.255.0 up" >> ~/.bashrc
$ source ~/.bashrc
```

---
### MHA 의존성 패키지 설치(모든 노드 실행)

```bash
$ sudo apt-get install -y \
  libdbd-mysql-perl \
  libconfig-tiny-perl \
  liblog-dispatch-perl \
  libparallel-forkmanager-perl

$ sudo apt-get install -y \
  perl \
  libdbi-perl \
  libio-socket-ssl-perl \
  libclass-methodmaker-perl \
  libjson-perl \
  libparams-validate-perl \
  libterm-readkey-perl \
  libmodule-install-perl \
  libnet-ssleay-perl \
  libio-socket-inet6-perl
```

---
### 각 노드 및 VIP 호스트 등록

모든 노드에서 /etc/hosts 에 모든 노드의 정보를 작성해주어야 합니다.
```bash
$ cat /etc/hosts
192.168.1.162   mha-manager
192.168.1.38    db-node-01
192.168.1.18    db-node-02
192.168.1.254   db-node-03
192.168.10.10   mha-master-vip
```

---
### ssh-copy-id
MHA는 ssh기반으로 동작하기에, 각 노드끼리 ssh 접속시 비밀번호 없이 접속되도록 ssh-key 를 복사한다.
```bash
$ ssh-keygen
$ ssh-copy-id db-node-01
$ ssh-copy-id db-node-02
$ ssh-copy-id db-node-03
```

---
### MHA manager, MHA node 설치
MHA 는 git 을 통하여 배포되며 git clone을 통하여 받을 수 있다.
manager : https://github.com/yoshinorim/mha4mysql-manager
node : https://github.com/yoshinorim/mha4mysql-node

- mha4mysql-node, manager 서버와 db node 모두 섶치
```bash
$ git clone https://github.com/yoshinorim/mha4mysql-node.git
$ cd mha4mysql-node/
$ perl Makefile.PL
$ make; make install
```
혹여나 에러가뜬다면 DBD:mysql 모듈이 정상적으로 설치되어있는지 확인.

해당 모듈을 사용하여 mysql 간의 통신을 하기에 꼭 설치되어 있어야한다.

설치되어있다면, 아래와 같이 버전명이 뜬다.

```bash
$ perl -MDBD::mysql -e 'print "$DBD::mysql::VERSION\n"
4.050
```
설치가 안되어있다면 cpan(perl 레포지토리 이용 명령어) 를 사용하여 개별적으로 설치 진행.
```bash
$ cpan -i DBD:mysql
```

- mha4mysql-manager, manager 서버에 설치
```bash
$ git clone https://github.com/yoshinorim/mha4mysql-manager
$ cd mha4mysql-manager
$ perl Makefile.PL
$ make; make install
```

- manager sample 복사
```
$ mkdir -p /root/mha/conf
$ mkdir -p /root/mha/scripts

$ cp conf/* /root/mha/conf
$ cp scripts/* /root/mha/scripts
```
- mha_change_vip.sh 파일 생성
아래 스크립트를 복사하여 사용하되, 인터페이스명은 자신에게 맞추어 수정한다.

```bash
cd /root/mha/scripts
cat mha_change_vip.sh
#!/bin/bash
## Fail-Over VIP Change

V_NEW_MASTER=`cat /etc/hosts | grep $1 | awk '{print $2}'`
V_EXIST_VIP_CHK=`ping -c 1 -W 1 mha-master-vip | grep "packet loss" | awk '{print $6}'`
V_VIP_IP=`cat /etc/hosts | grep mha-master-vip | awk '{print $1}'`

if [ $V_EXIST_VIP_CHK = "0%" ]
then
        echo "VIP IS Alive, VIP Relocate $V_NEW_MASTER "
        /bin/ssh -o StrictHostKeyChecking=no mha-master-vip /bin/sudo /sbin/ifconfig ens3:0 down &

        ssh -o StrictHostKeyChecking=no $V_NEW_MASTER /bin/sudo /sbin/ifconfig ens3:0 $V_VIP_IP netmask 255.255.255.0
        ssh -o StrictHostKeyChecking=no $V_NEW_MASTER /sbin/arping -c 5 -D -I ens3 -s $V_VIP_IP $V_VIP_IP

        VIP_NOHUP_PS=`ps -ef| grep "ifconfig en3:0" | grep ssh | grep -v grep | awk '{print $2}'` && kill -9 $VIP_NOHUP_PS

        elif [ $V_EXIST_VIP_CHK = "100%" ]
        then
            echo "VIP IS dead, VIP Relocate $V_NEW_MASTER "
            /bin/ssh -o StrictHostKeyChecking=no $V_NEW_MASTER /bin/sudo /sbin/ifconfig ens3:0 $V_VIP_IP netmask 255.255.255.0
            /bin/ssh -o StrictHostKeyChecking=no $V_NEW_MASTER /sbin/arping -c 5 -D -I ens3 -s $V_VIP_IP $V_VIP_IP
fi
```
해당 스크립트를 사용하면 어떠한 노드에 vip를 올릴지 선택할 수 있다.
이 스크립트는 이후 설명에서 mha 소스에 추가할것이다.

```bash
# test
root@mha-test:~/mha/scripts# ./mha_change_vip.sh db-node-02
VIP IS dead, VIP Relocate db-node-02
arping: Weird MAC addr 192.168.10.10
root@mha-test:~/mha/scripts# ./mha_change_vip.sh db-node-01
VIP IS dead, VIP Relocate db-node-01
arping: Weird MAC addr 192.168.10.10
```

---
### mha 용 계정 생성(master node에서 실행)
```sql
CREATE USER mha@'%' IDENTIFIED BY 'qwe1212';
GRANT ALL PRIVILEGES ON *.* TO mha@'%';
```
slave 에서 확인
```sql
mysql> select user,host from mysql.user where user='mha';
+------+------+
| user | host |
+------+------+
| mha  | %    |
+------+------+
1 row in set (0.00 sec)

```

---
### mha-manager conf 생성및 설정
- /root/mha/app1.cnf

```bash
[server default]
# DB mha 유저계정 정보
user=mha
password=qwe1212
# SSH 접속 유저 아이디
ssh_user=root
# replication 유저 계정정보
repl_user=repl_user
repl_password=qwe1212

# MHA 로그 저장디렉토리 위치
manager_workdir=/root/mha/app1
manager_log=/root/mha/app1/app1.log

remote_workdir=/root/mha/app1
master_binlog_dir=/usr/local/mysql/logs

# 아래 구문을 통하여 fail 시 master 로 전환이 가능한 노드 탐색
secondary_check_script=/usr/local/bin/masterha_secondary_check -s 192.168.1.38 -s 192.168.1.18 -s 192.168.1.254 --user=root --master_host=192.168.1.38 --master_ip=192.168.1.38 --master_port=3306 --master_password=qwe1212

master_ip_failover_script=/root/mha/scripts/master_ip_failover
master_ip_online_change_script=/root/mha/scripts/master_ip_online_change
#master_ip_online_change_script=/mha/scripts/master_ip_online_change

[server1]
hostname=db-node-01
candidate_master=1

[server2]
hostname=db-node-02
candidate_master=1

[server3]
hostname=db-node-03
candidate_master=1
```

- /root/mha/masterha_default.cnf

다른 cnf 파일을 생성하지 않았을때 기본적으로 적용되는 cnf 이다. 이미 app1.cnf 에 아래 내용을 모두 적어두었으나, 혹시 모르니 작성해둔다.
```bash
[server default]
user=mha
password=qwe1212

ssh_user=root
ssh_port=22

repl_user=repli_user
repl_password=qwe1212

ping_interval=1
```

---
### 소스코드 수정

mysql 8 버전에서 mha 를 사용하기 위해서는 몇가지 소스코드 수정이 필요하다. mysql8 로 넘어오면서 인종차별적 문구들에대한 대거 수정이 있었기에 수정이 필요하다. 구글링을통해 몇분이 수정해둔 코드를 인용하였다.


- master_ip_online_change 수정
```
$ vi master_ip_online_change


= 변경 전 - 149 라인
## Drop application user so that nobody can connect. Disabling per-session binlog beforehand
$orig_master_handler->disable_log_bin_local();
print current_time_us() . " Drpping app user on the orig master..n";
FIXME_xxx_drop_app_user($orig_master_handler);


= 변경 후 , 주석 처리
## Drop application user so that nobody can connect. Disabling per-session binlog beforehand
## $orig_master_handler->disable_log_bin_local();
## print current_time_us() . " Drpping app user on the orig master..n";
## FIXME_xxx_drop_app_user($orig_master_handler);


= 변경 전 - 244 라인
## Creating an app user on the new master
print current_time_us() . " Creating app user on the new master..n";
FIXME_xxx_create_app_user($new_master_handler);
$new_master_handler->enable_log_bin_local();
$new_master_handler->disconnect();


= 변경 후 , 주석 처리
## Creating an app user on the new master
## print current_time_us() . " Creating app user on the new master..n";
## FIXME_xxx_create_app_user($new_master_handler);
## $new_master_handler->enable_log_bin_local();
## $new_master_handler->disconnect();


== mha_change_vip.sh 추가
## Update master ip on the catalog database, etc

system("/bin/bash /masterha/scripts/mha_change_vip.sh $new_master_ip"); <-- 추가

$exit_code = 0;
};
```
>출처 : https://hoing.io/archives/92

mha 소스 변경
- usr/share/perl5/MHA/Server.pm
``` bash
# ori
339 rules, temporarily executing CHANGE MASTER to dummy host, and
345 "%s: SHOW SLAVE STATUS returned empty result. To check replication filtering rules, temporarily executing CHANGE MASTER to a dummy host.",
348 $dbhelper->execute("CHANGE MASTER TO MASTER_HOST='dummy_host'");

# modi
339 # rules, temporarily executing CHANGE REPLICATION SOURCE to dummy host, and
345 "%s: SHOW SLAVE STATUS returned empty result. To check replication filtering rules, temporarily executing CHANGE REPLICATION SOURCE to a dummy host.",
348 $dbhelper->execute("CHANGE REPLICATION SOURCE TO SOURCE_HOST='dummy_host'");
```
- /usr/local/share/perl5/MHA/ServerManager.pm
```bash
# ori
1294 " All other slaves should start replication from here. Statement should be: CHANGE MASTER TO MASTER_HOST='%s', MASTER_PORT=%d, MASTER_AUTO_POSITION=1, MASTER_USER='%s', MASTER_PASSWORD='xxx';",
1307 " All other slaves should start replication from here. Statement should be: CHANGE MASTER TO MASTER_HOST='%s', MASTER_PORT=%d, MASTER_LOG_FILE='%s', MASTER_LOG_POS=%d, MASTER_USER='%s', MASTER_PASSWORD='xxx';",
1354 $log->info(" Executed CHANGE MASTER.");
1356 # After executing CHANGE MASTER, relay_log_purge is automatically disabled.

#modi
1294 " All other slaves should start replication from here. Statement should be: CHANGE REPLICATION SOURCE TO SOURCE_HOST='%s', SOURCE_PORT=%d, SOURCE_AUTO_POSITION=1, SOURCE_USER='%s', SOURCE_PASSWORD='xxx';",
1307 " All other slaves should start replication from here. Statement should be: CHANGE REPLICATION SOURCE TO SOURCE_HOST='%s', SOURCE_PORT=%d, SOURCE_LOG_FILE='%s', SOURCE_LOG_POS=%d, SOURCE_USER='%s', SOURCE_PASSWORD='xxx';",
1354 $log->info(" CHANGE REPLICATION SOURCE.");
1356 # After executing CHANGE REPLICATION SOURCE, relay_log_purge is automatically disabled.
```
- /usr/local/share/perl5/MHA/DBHelper.pm
```bash
# ori
71 "CHANGE MASTER TO MASTER_HOST='%s', MASTER_PORT=%d, MASTER_USER='%s', MASTER_PASSWORD='%s', MASTER_LOG_FILE='%s', MASTER_LOG_POS=%d";
73 "CHANGE MASTER TO MASTER_HOST='%s', MASTER_PORT=%d, MASTER_USER='%s', MASTER_LOG_FILE='%s', MASTER_LOG_POS=%d"; 
75 "CHANGE MASTER TO MASTER_HOST='%s', MASTER_PORT=%d, MASTER_USER='%s', MASTER_PASSWORD='%s', MASTER_AUTO_POSITION=1";
77 "CHANGE MASTER TO MASTER_HOST='%s', MASTER_PORT=%d, MASTER_USER='%s', MASTER_AUTO_POSITION=1";
87 use constant Stop_IO_Thread_SQL     => "STOP REPLICA IO_THREAD";
88 use constant Start_IO_Thread_SQL    => "START REPLICA IO_THREAD";
89 use constant Start_Slave_SQL        => "START REPLICA";
90 use constant Stop_Slave_SQL         => "STOP REPLICA";
91 use constant Start_SQL_Thread_SQL   => "START REPLICA SQL_THREAD";
92 use constant Stop_SQL_Thread_SQL    => "STOP REPLICA SQL_THREAD";

# modi
71 "CHANGE REPLICATION SOURCE TO SOURCE_HOST='%s', SOURCE_PORT=%d, SOURCE_USER='%s', SOURCE_PASSWORD='%s', SOURCE_LOG_FILE='%s', SOURCE_LOG_POS=%d";
73 "CHANGE REPLICATION SOURCE TO SOURCE_HOST='%s', SOURCE_PORT=%d, SOURCE_USER='%s', SOURCE_LOG_FILE='%s', SOURCE_LOG_POS=%d";
75 "CHANGE REPLICATION SOURCE TO SOURCE_HOST='%s', SOURCE_PORT=%d, SOURCE_USER='%s', SOURCE_PASSWORD='%s', SOURCE_AUTO_POSITION=1";
77 "CHANGE REPLICATION SOURCE TO SOURCE_HOST='%s', SOURCE_PORT=%d, SOURCE_USER='%s', SOURCE_AUTO_POSITION=1";
87 use constant Stop_IO_Thread_SQL     => "STOP REPLICA IO_THREAD";
88 use constant Start_IO_Thread_SQL    => "START REPLICA IO_THREAD";
89 use constant Start_Slave_SQL        => "START REPLICA";
90 use constant Stop_Slave_SQL         => "STOP REPLICA";
91 use constant Start_SQL_Thread_SQL   => "START REPLICA SQL_THREAD";
92 use constant Stop_SQL_Thread_SQL    => "STOP REPLICA SQL_THREAD";
```
>출처 : https://blog.naver.com/theswice/222489176002 , https://hoing.io/archives/3201


---
### ssh 및 replication test
설치 및 설정이 모두 마무리 되었으면, ssh 연결은 정상적인지 replication은 정상적으로 작동중인지 확인한다.
```bash
$ masterha_check_ssh --conf=/root/mha/conf/app1.cnf
Fri Dec  1 16:36:12 2023 - [info] Reading default configuration from /etc/masterha_default.cnf..
Fri Dec  1 16:36:12 2023 - [info] Reading application default configuration from /etc/app1.cnf..
Fri Dec  1 16:36:12 2023 - [info] Reading server configuration from /etc/app1.cnf..
Fri Dec  1 16:36:12 2023 - [info] Starting SSH connection tests..
Fri Dec  1 16:36:14 2023 - [debug]
Fri Dec  1 16:36:12 2023 - [debug]  Connecting via SSH from root@db-node-01(192.168.1.38:22) to root@db-node-02(192.168.1.18:22)..
Fri Dec  1 16:36:13 2023 - [debug]   ok.
Fri Dec  1 16:36:13 2023 - [debug]  Connecting via SSH from root@db-node-01(192.168.1.38:22) to root@db-node-03(192.168.1.254:22)..
Fri Dec  1 16:36:14 2023 - [debug]   ok.
Fri Dec  1 16:36:14 2023 - [debug]
Fri Dec  1 16:36:12 2023 - [debug]  Connecting via SSH from root@db-node-02(192.168.1.18:22) to root@db-node-01(192.168.1.38:22)..
Fri Dec  1 16:36:14 2023 - [debug]   ok.
Fri Dec  1 16:36:14 2023 - [debug]  Connecting via SSH from root@db-node-02(192.168.1.18:22) to root@db-node-03(192.168.1.254:22)..
Fri Dec  1 16:36:14 2023 - [debug]   ok.
Fri Dec  1 16:36:15 2023 - [debug]
Fri Dec  1 16:36:13 2023 - [debug]  Connecting via SSH from root@db-node-03(192.168.1.254:22) to root@db-node-01(192.168.1.38:22)..
Fri Dec  1 16:36:14 2023 - [debug]   ok.
Fri Dec  1 16:36:14 2023 - [debug]  Connecting via SSH from root@db-node-03(192.168.1.254:22) to root@db-node-02(192.168.1.18:22)..
Fri Dec  1 16:36:15 2023 - [debug]   ok.
Fri Dec  1 16:36:15 2023 - [info] All SSH connection tests passed successfully.
Use of uninitialized value in exit at /usr/local/bin/masterha_check_ssh line 44.

$ masterha_check_repl --conf=/root/mha/conf/app1.cnf
~
~
Fri Dec  1 16:37:18 2023 - [info] Checking replication health on db-node-02..
Fri Dec  1 16:37:18 2023 - [info]  ok.
Fri Dec  1 16:37:18 2023 - [info] Checking replication health on db-node-03..
Fri Dec  1 16:37:18 2023 - [info]  ok.
Fri Dec  1 16:37:18 2023 - [info] Checking master_ip_failover_script status:
Fri Dec  1 16:37:18 2023 - [info]   /root/mha/scripts/master_ip_failover --command=status --ssh_user=root --orig_master_host=db-node-01 --orig_master_ip=192.168.1.38 --orig_master_port=3306
Fri Dec  1 16:37:19 2023 - [info]  OK.
Fri Dec  1 16:37:19 2023 - [warning] shutdown_script is not defined.
Fri Dec  1 16:37:19 2023 - [debug]  Disconnected from db-node-01(192.168.1.38:3306)
Fri Dec  1 16:37:19 2023 - [debug]  Disconnected from db-node-02(192.168.1.18:3306)
Fri Dec  1 16:37:19 2023 - [debug]  Disconnected from db-node-03(192.168.1.254:3306)
Fri Dec  1 16:37:19 2023 - [info] Got exit code 0 (Not master dead).
```

*error #1*

```bash
$ /usr/local/bin/masterha_check_repl --conf=/etc/app1.cnf
Thu Nov 30 14:02:21 2023 - [info] Reading default configuration from /etc/masterha_default.cnf..
Thu Nov 30 14:02:21 2023 - [info] Reading application default configuration from /etc/app1.cnf..
Thu Nov 30 14:02:21 2023 - [info] Reading server configuration from /etc/app1.cnf..
Thu Nov 30 14:02:21 2023 - [info] MHA::MasterMonitor version 0.58.
Thu Nov 30 14:02:21 2023 - [debug] Connecting to servers..
Thu Nov 30 14:02:21 2023 - [debug] Got MySQL error when connecting db-node-01(192.168.1.38:3306) :2061:Authentication plugin 'caching_sha2_password' reported error: Authentication requires secure connection.
Thu Nov 30 14:02:21 2023 - [debug] Got MySQL error when connecting db-node-02(192.168.1.18:3306) :2061:Authentication plugin 'caching_sha2_password' reported error: Authentication requires secure connection.
Thu Nov 30 14:02:21 2023 - [debug] Got MySQL error when connecting db-node-03(192.168.1.254:3306) :2061:Authentication plugin 'caching_sha2_password' reported error: Authentication requires secure connection.
Thu Nov 30 14:02:22 2023 - [error][/usr/local/share/perl/5.34.0/MHA/ServerManager.pm, ln188] There is no alive server. We can't do failover
Thu Nov 30 14:02:22 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln427] Error happened on checking configurations.  at /usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm line 329.
Thu Nov 30 14:02:22 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln525] Error happened on monitoring servers.
Thu Nov 30 14:02:22 2023 - [info] Got exit code 1 (Not master dead).
```
mysql8 은 기본적으로 sha2 방식을 이용하여 계정접속을 암호화한다, native password를 사용하면 해결
```sql
alter user mha@'%' identified with mysql_native_password by 'qwe1212';
```

*error #2*


```bash
/usr/local/bin/masterha_check_repl --conf=/etc/app1.cnf
Thu Nov 30 14:03:31 2023 - [info] Reading default configuration from /etc/masterha_default.cnf..
Thu Nov 30 14:03:31 2023 - [info] Reading application default configuration from /etc/app1.cnf..
Thu Nov 30 14:03:31 2023 - [info] Reading server configuration from /etc/app1.cnf..
Thu Nov 30 14:03:31 2023 - [info] MHA::MasterMonitor version 0.58.
Thu Nov 30 14:03:31 2023 - [debug] Connecting to servers..
Thu Nov 30 14:03:32 2023 - [debug]  Connected to: db-node-01(192.168.1.38:3306), user=mha
Thu Nov 30 14:03:32 2023 - [debug]  Number of slave worker threads on host db-node-01(192.168.1.38:3306): 4
Thu Nov 30 14:03:32 2023 - [debug]  Connected to: db-node-02(192.168.1.18:3306), user=mha
Thu Nov 30 14:03:32 2023 - [debug]  Number of slave worker threads on host db-node-02(192.168.1.18:3306): 4
Thu Nov 30 14:03:32 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln427] Error happened on checking configurations. Redundant argument in sprintf at /usr/local/share/perl/5.34.0/MHA/NodeUtil.pm line 195.
Thu Nov 30 14:03:32 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln525] Error happened on monitoring servers.
Thu Nov 30 14:03:32 2023 - [info] Got exit code 1 (Not master dead).
```
NodeUtil.pm 수정
```diff
193 sub parse_mysql_version($) {
194   my $str = shift;
+ 195   ($str) =  $str =~ m/^[^-]*/g;
196   my $result = sprintf( '%03d%03d%03d', $str =~ m/(\d+)/g );
197   return $result;
198 }
```

*error #3*

```bash
~
~
Thu Nov 30 14:10:10 2023 - [debug]   ok.
Thu Nov 30 14:10:11 2023 - [info] All SSH connection tests passed successfully.
Thu Nov 30 14:10:11 2023 - [info] Checking MHA Node version..
Thu Nov 30 14:10:12 2023 - [info]  Version check ok.
Thu Nov 30 14:10:12 2023 - [info] Checking SSH publickey authentication settings on the current master..
Thu Nov 30 14:10:12 2023 - [debug] SSH connection test to db-node-01, option -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o BatchMode=yes -o ConnectTimeout=5, timeout 5
Thu Nov 30 14:10:12 2023 - [info] HealthCheck: SSH to db-node-01 is reachable.
Thu Nov 30 14:10:13 2023 - [info] Master MHA Node version is 0.58.
Thu Nov 30 14:10:13 2023 - [info] Checking recovery script configurations on db-node-01(192.168.1.38:3306)..
Thu Nov 30 14:10:13 2023 - [info]   Executing command: save_binary_logs --command=test --start_pos=4 --binlog_dir=/usr/local/mysql
/logs --output_file=/root/mha/app1/save_binary_logs_test --manager_version=0.58 --start_file=binlog.000006 --debug
Thu Nov 30 14:10:13 2023 - [info]   Connecting to root@192.168.1.38(db-node-01:22)..
Failed to save binary log: Binlog not found from /usr/local/mysql/logs! If you got this error at MHA Manager, please set "master_binlog_dir=/path/to/binlog_directory_of_the_master" correctly in the MHA Manager's configuration file and try again.
 at /usr/local/bin/save_binary_logs line 123.
        eval {...} called at /usr/local/bin/save_binary_logs line 70
        main::main() called at /usr/local/bin/save_binary_logs line 66
Thu Nov 30 14:10:13 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln161] Binlog setting check failed!
Thu Nov 30 14:10:13 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln408] Master configuration failed.
Thu Nov 30 14:10:13 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln427] Error happened on checking configurations.  at /usr/local/bin/masterha_check_repl line 48.
Thu Nov 30 14:10:13 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln525] Error happened on monitoring servers.
Thu Nov 30 14:10:13 2023 - [info] Got exit code 1 (Not master dead).
```
app1.cnf 의 binlog master노드 위치에 맞추어 수정
```
master_binlog_dir=/var/log/mysql
```


---

### masterha_manager 실행하기
maneger server 에서 다른 노드들을 관리하기위해 백그라운드로 매니저 프로그램을 실행한다.
```bash
$ nohup masterha_manager --conf=/root/mha/app1.cnf --last_failover_minute=1 &
```
필자는 실행을 간단하게하기 위하여 아래와같이 bashrc 에 등록해두었다.
```bash
alias sshcheck='masterha_check_ssh --conf=/etc/app1.cnf'
alias replcheck='masterha_check_repl --conf=/etc/app1.cnf'
alias start='nohup masterha_manager --conf=/etc/app1.cnf &'
alias status='masterha_check_status --conf=/etc/app1.cnf'
alias stop='masterha_stop --conf=/etc/app1.cnf'
```

### Failover test

failover가 정상적으로 작동하는지 확인하기위해, master node 에 장애를 발생시킨다.
```bash
# db-node-01
$ systemctl stop mysql.service
# mha-manager
$ tail -f /root/mha/app1/app1.log

~
~
Fri Dec  1 17:11:06 2023 - [info] All new slave servers recovered successfully.
Fri Dec  1 17:11:06 2023 - [info]
Fri Dec  1 17:11:06 2023 - [info] * Phase 5: New master cleanup phase..
Fri Dec  1 17:11:06 2023 - [info]
Fri Dec  1 17:11:06 2023 - [info] Resetting slave info on the new master..
Fri Dec  1 17:11:06 2023 - [debug]  Clearing slave info..
Fri Dec  1 17:11:06 2023 - [debug]  Stopping slave IO/SQL thread on db-node-02(192.168.1.18:3306)..
Fri Dec  1 17:11:06 2023 - [debug]   done.
Fri Dec  1 17:11:06 2023 - [debug]  SHOW SLAVE STATUS shows new master does not replicate from anywhere. OK.
Fri Dec  1 17:11:06 2023 - [info]  db-node-02: Resetting slave info succeeded.
Fri Dec  1 17:11:06 2023 - [info] Master failover to db-node-02(192.168.1.18:3306) completed successfully.
Fri Dec  1 17:11:06 2023 - [debug]  Disconnected from db-node-02(192.168.1.18:3306)
Fri Dec  1 17:11:06 2023 - [debug]  Disconnected from db-node-03(192.168.1.254:3306)
Fri Dec  1 17:11:06 2023 - [info]

----- Failover Report -----

app1: MySQL Master failover db-node-01(192.168.1.38:3306) to db-node-02(192.168.1.18:3306) succeeded

Master db-node-01(192.168.1.38:3306) is down!

Check MHA Manager logs at mha-test:/root/mha/app1/app1.log for details.

Started automated(non-interactive) failover.
Invalidated master IP address on db-node-01(192.168.1.38:3306)
The latest slave db-node-02(192.168.1.18:3306) has all relay logs for recovery.
Selected db-node-02(192.168.1.18:3306) as a new master.
db-node-02(192.168.1.18:3306): OK: Applying all logs succeeded.
db-node-02(192.168.1.18:3306): OK: Activated master IP address.
db-node-03(192.168.1.254:3306): This host has the latest relay log events.
Generating relay diff files from the latest slave succeeded.
db-node-03(192.168.1.254:3306): OK: Applying all logs succeeded. Slave started, replicating from db-node-02(192.168.1.18:3306)
db-node-02(192.168.1.18:3306): Resetting slave info succeeded.
Master failover to db-node-02(192.168.1.18:3306) completed successfully.
```

로그를 확인해보면 stop이 발생한 이후 수초내에 가용가능한 db를 확인후, db-node-02를 master로 승격한것을 볼 수 있다.

위와 같이 동작한다면 정상

---
### Failover 복구

db-node-01 의 장애 복구를 위하여 mysql를 다시 start하고 새로운 master node 인 db-node-02를 바라보도록 설정한다.

```bash
$ systemctl start mysql.service
```
```sql
mysql> CHANGE REPLICATION SOURCE TO SOURCE_HOST='db-node-02', SOURCE_PORT=3306, 
SOURCE_LOG_FILE='binlog.000008', SOURCE_LOG_POS=578, 
SOURCE_USER='repl_user', SOURCE_PASSWORD='qwe1212';
```

db-node-02 에서 slave가 모두 붙어있는지 확인한다.
```sql
mysql>  show slave hosts;
+-----------+-------------+------+-----------+--------------------------------------+
| Server_id | Host        | Port | Master_id | Slave_UUID                           |
+-----------+-------------+------+-----------+--------------------------------------+
|         3 | db-node-03  | 3306 |         3 | c0d41bc7-8d89-11ee-9245-fa163e8c7720 |
+-----------+-------------+------+-----------+--------------------------------------+
|         1 | db-node-01  | 3306 |         1 | c71239ca-23o9-12cd-0917-zxbniopa6789 |
+-----------+-------------+------+-----------+--------------------------------------+
```

설정이 모두 완료되었다면 masterha_switch 를 통하여 master 노드를 변경할수 있다.

```bash
# 변경전 상태체크
masterha_check_repl  --conf=/root/mha/app1.cnf
# mha manager stop
masterha_stop --conf=/root/mha/app1.cnf
# switch 시작
masterha_master_switch --master_state=alive \ 
--conf=/root/mha/app1.cnf --new_master_host=db-node-01 \ 
--interactive=0
```

에러없이 실행되었다면 mysql 에서

``show slave status``, ``show master status``

를 통해, 정상적으로 변경된것을 확인할 수 있다.