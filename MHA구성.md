# MHA 란?

기본적으로 DB를 Replication 구성을하여 Master 와 Slave 를 나눈뒤 하나의 VIP를 공유시켜 서비스한다.
Master DB에서 장애가 발생할시 MHA Manager 는 failover를 위해 Slave 를 Master로 승격시켜 서비스 다운 타임을 최소화하는 auto failover 솔루션이다.

따라서 서

---

## 환경 구성

| 역할        | 호스트 이름 | 운영체제           | external ip    | internal ip |
| ----------- | ----------- | ------------------ | -------------- | ----------- |
| MHA Manager | man         | Ubuntu 22.04 jammy | 115.68.249.237 | 10.101.0.15 |
| mha_node1   | acs         | Ubuntu 22.04 jammy | 115.68.248.233 | 10.101.0.12 |
| mha_node2   | node02      | Ubuntu 22.04 jammy | 115.68.248.201 | 10.101.0.26 |

![](/home/kimbh/문서/김병학_공부/draw.io/테스트MHA구성도.jpg)

#### Mysql install

```bash
$ apt update && apt upgrade
$ apt install -y mysql-server perl 
$ mysql --version
mysql  Ver 8.0.35-0ubuntu0.22.04.1 for Linux on x86_64 ((Ubuntu))
```

#### my.cnf 수정

아래 내용을 my.cnf에 추가하여 사용

(* my.cnf 가 안보일때 `mysql --help | grep -A 1 'Default options'`)

**Master node**

```bash
[msyqld]
# server-id는 master와 slave가 다르게 설정
server-id=1

# Binlog의 파일명을 기재합니다.
log-bin=/usr/local/mysql/logs/binlog

# binary log 가 일정 쿼리 이후 동기화 되도록 설정
sync_binlog=1

# binlog 의 size및 format 지정
binlog_cache_size=2M
binlog_format=ROW
max_binlog_size=512M

# binlog 삭제 주기 설정, mysql 5 버전은 expire_logs_days 사용
# 604800sec = 7days
binlog_expire_logs_seconds=604800

# log-bin-trust-function-creators의 기본값은 0이며, 0으로 설정되어있을시 유저계정은 함수를 수정 및 생성 불가능, 이를 허용하는 옵션
log-bin-trust-function-creators=1

#  SHOW SLAVE HOSTS에서 표시되는 이름을 지정
# 각 DB의 호스트네임으로 show slave hosts 에서 정보로 활용
report-host=acs

# 각 DB의 호스트네임으로 show slave hosts 에서 정보로 활용
relay-log=/usr/local/mysql/logs/relay_log
relay-log-index=/usr/local/mysql/logs/relay_log.index
relay_log_purge=off
log_slave_updates=ON
```

**Slave node** 

```bash
[msyqld]
# server-id는 master와 slave가 다르게 설정
server-id=2

### Replication
# Binlog의 파일명을 기재합니다.
log-bin=/usr/local/mysql/logs/binlog

# binary log 가 일정 쿼리 이후 동기화 되도록 설정
sync_binlog=1

# binlog 의 size및 format 지정
binlog_cache_size=2M
binlog_format=ROW
max_binlog_size=512M

# binlog 삭제 주기 설정, mysql 5 버전은 expire_logs_days 사용
# 604800sec = 7days
binlog_expire_logs_seconds=604800

# log-bin-trust-function-creators의 기본값은 0이며, 0으로 설정되어있을시 유저계정은 함수를 수정 및 생성 불가능, 이를 허용하는 옵션
log-bin-trust-function-creators=1

# SHOW SLAVE HOSTS에서 표시되는 이름을 지정
# 각 DB의 호스트네임으로 show slave hosts 에서 정보로 활용
report-host=acs2

relay-log=/usr/local/mysql/logs/relay_log
relay-log-index=/usr/local/mysql/logs/relay_log.index
relay_log_purge=off
log_slave_updates=ON
```

이후 mysql 재시작

```bash
$ systemctl restart mysql.service
```



#### Replication 구성

###### 모든 node

repelication 계정 생성 및 권한 부여

```mysql
mysql> CREATE USER 'repliuser'@'%' IDENTIFIED BY 'qwe1212!q';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repliuser'@'%';

mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: binlog.000003
         Position: 1172
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)

mysql> CHANGE MASTER TO MASTER_HOST='acs', MASTER_USER='repliuser',MASTER_PASSWORD='qwe1212!Q',
MASTER_LOG_FILE='binlog.000003',
MASTER_LOG_POS=154;

mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Connecting to source
                  Master_Host: acs
                  Master_User: repliuser
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000003
          Read_Master_Log_Pos: 154
               Relay_Log_File: kimbh0132-226543-relay-bin.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: binlog.000003
             Slave_IO_Running: Connecting
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
          Exec_Master_Log_Pos: 154
              Relay_Log_Space: 157
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: NULL
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 2005
                Last_IO_Error: Error connecting to source 'repliuser@acs:3306'. This was attempt 1/86400, with a delay of 60 seconds between attempts. Message: Unknown MySQL server host 'acs' (-3)
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 0
                  Master_UUID:
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp: 231110 14:05:11
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

```

  

---

MHA Manager 내용 추가 필요

---

**error #1**

```bash
$ root@kimbh0132-227691:/usr/local/src/mha4mysql-node-0.58# masterha_check_repl --conf=/masterha/conf/app1.cnf
Mon Nov 20 09:38:47 2023 - [info] Reading default configuration from /etc/masterha_default.cnf..
Mon Nov 20 09:38:47 2023 - [info] Reading application default configuration from /masterha/conf/app1.cnf..
Mon Nov 20 09:38:47 2023 - [info] Reading server configuration from /masterha/conf/app1.cnf..
Mon Nov 20 09:38:47 2023 - [info] MHA::MasterMonitor version 0.58.
Mon Nov 20 09:38:48 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln427] Error happened on checking configurations. Redundant argument in sprintf at /usr/local/share/perl/5.34.0/MHA/NodeUtil.pm line 195.
Mon Nov 20 09:38:48 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln525] Error happened on monitoring servers.
Mon Nov 20 09:38:48 2023 - [info] Got exit code 1 (Not master dead).

```

해결방법

```bash
$ vim /usr/local/share/perl/5.34.0/MHA/NodeUtil.pm
```

```diff
 sub parse_mysql_version($) {
   my $str = shift;
+  ($str) =  $str =~ m/^[^-]*/g;
   my $result = sprintf( '%03d%03d%03d', $str =~ m/(\d+)/g );
   return $result;
 }

 sub parse_mysql_major_version($) {
   my $str = shift;
-  my $result = sprintf( '%03d%03d', $str =~ m/(\d+)/g );
+  ($str) =  $str =~ m/^[^-]*/g;
+  my $result = sprintf( '%03d%03d%03d', $str =~ m/(\d+)/g );
   return $result;
 }
```

193~203번 라인 변경



**error #2**

```bash
Mon Nov 20 10:27:32 2023 - [info] Checking SSH publickey authentication and checking recovery script configurations on all alive slave servers..
Mon Nov 20 10:27:32 2023 - [info]   Executing command : apply_diff_relay_logs --command=test --slave_user='dbmha' --slave_host=node2 --slave_ip=115.68.248.233 --slave_port=3306 --workdir=/masterha/conf/app1 --target_version=8.0.35-0ubuntu0.22.04.1 --manager_version=0.58 --relay_dir=/var/lib/mysql --current_relay_log=relay-bin.000027  --slave_pass=xxx
Mon Nov 20 10:27:32 2023 - [info]   Connecting to root@115.68.248.233(node2:22)..
  Checking slave recovery environment settings..
    Relay log found at /var/lib/mysql, up to relay-bin.000028
    Temporary relay log file is /var/lib/mysql/relay-bin.000028
    Checking if super_read_only is defined and turned on..install_driver(mysql) failed: Can't locate DBD/mysql.pm in @INC (you may need to install the DBD::mysql module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.34.0 /usr/local/share/perl/5.34.0 /usr/lib/x86_64-linux-gnu/perl5/5.34 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl-base /usr/lib/x86_64-linux-gnu/perl/5.34 /usr/share/perl/5.34 /usr/local/lib/site_perl) at (eval 31) line 3.
Perhaps the DBD::mysql perl module hasn't been fully installed,
or perhaps the capitalisation of 'mysql' isn't right.
Available drivers: DBM, ExampleP, File, Gofer, Mem, Proxy, Sponge.
 at /usr/local/share/perl/5.34.0/MHA/SlaveUtil.pm line 239.
Mon Nov 20 10:27:33 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln208] Slaves settings check failed!
Mon Nov 20 10:27:33 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln416] Slave configuration failed.
Mon Nov 20 10:27:33 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln427] Error happened on checking configurations.  at /usr/local/bin/masterha_check_repl line 48.
Mon Nov 20 10:27:33 2023 - [error][/usr/local/share/perl/5.34.0/MHA/MasterMonitor.pm, ln525] Error happened on monitoring servers.
```

---

해결 못하여서 rocky 8.4 으로 진행

---

```bash
$ dnf config-manager --set-enabled powertools
$ yum install epel-release
$ yum update -y && yum upgrade
$ yum install perl-Module-Install
$ yum install perl-DBD-MySQL \
perl-Config-Tiny \
perl-Log-Dispatch \
perl-Parallel-ForkManager \
perl-Time-HiRes \
perl-CPAN \
perl-Module-Install

# mha4mysql-manager 설치
$ cd /usr/local/src
$ wget https://github.com/yoshinorim/mha4mysql-manager/releases/download/v0.58/mha4mysql-manager-0.58.tar.gz
$ tar -xvzf mha4mysql-manager-0.58.tar.gz
$ cd mha4mysql-manager-0.58/
$ perl Makefile.PL
*** Module::AutoInstall version 1.06
*** Checking for Perl dependencies...
[Core Features]
- DBI                   ...loaded. (1.641)
- DBD::mysql            ...loaded. (4.046)
- Time::HiRes           ...loaded. (1.9758)
- Config::Tiny          ...loaded. (2.24)
- Log::Dispatch         ...loaded. (2.68)
- Parallel::ForkManager ...loaded. (2.02)
- MHA::NodeConst        ...missing.
==> Auto-install the 1 mandatory module(s) from CPAN? [y] y
*** Dependencies will be installed the next time you type 'make'.
*** Module::AutoInstall configuration finished.
Checking if your kit is complete...
Looks good
Warning: prerequisite MHA::NodeConst 0 not found.
Generating a Unix-style Makefile
Writing Makefile for mha4mysql::manager
Writing MYMETA.yml and MYMETA.json
$ make; make install

# mha4mysql-node 설치
$ wget https://github.com/yoshinorim/mha4mysql-node/releases/download/v0.58/mha4mysql-node-0.58.tar.gz
$ tar xvzf mha4mysql-node-0.58.tar.gz
$ cd mha4mysql-node-0.58/
$ perl Makefile.PLperl Makefile.PL
*** Module::AutoInstall version 1.06
*** Checking for Perl dependencies...
[Core Features]
- DBI        ...loaded. (1.641)
- DBD::mysql ...loaded. (4.046)
*** Module::AutoInstall configuration finished.
Checking if your kit is complete...
Looks good
Generating a Unix-style Makefile
Writing Makefile for mha4mysql::node
Writing MYMETA.yml and MYMETA.json
$ make; make install
$ cp /usr/local/src/mha4mysql-manager-0.58/samples/conf/* /etc/masterha/
$ cp /usr/local/src/mha4mysql-manager-0.58/samples/scripts/* /masterha/scripts/

```

