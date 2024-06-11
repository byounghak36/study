---
title: Galera Cluster & MySQL 5.7 설치_v1.4
tags:
  - galera
  - DB
  - replication
date: 2024_05_30
Modify_Date: 
reference: 
link:
---

# Galera Cluster & MySQL 8.0 설치

구성 서버 정보

OS : Ubuntu 22.04

Mirror Server : 115.68.248.161

test-server-1 : 10.101.0.4

test-server-2 : 10.101.0.20

VIP : 10.101.0.12

---

## 목차

1. Ubuntu Release(jammy), GaleraCluster mirror 서버 구축
2. test-server Galera Cluster & MySQL 8.0
3. keepalived 설치 및 설정

---

### Ubuntu Release(22.04), GaleraCluster mirror 서버 구축









**필수 패키지 설치**

MySQL을 설치하기전에 필요한 패키지를 먼저 설치합니다.

```bash
$ yum install ncurses ncurses-devel ncurses-libs openssl openssl-devel glibc bison make cmake readline gcc gcc-c++ wget autoconf automake libtool* libmcrypt* git patchelf libtirpc* rpcgen numactl numactl-devel ncurses-compat-libs libaio libaio-devel
```



**selinux 설정 해제**

```bash
$ vi /etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.

SELINUX=permissive

# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.

SELINUXTYPE=targeted
```

`setenforce 0` 을 해주거나 재부팅



**firewalld 해제**

```bash
$ systemctl stop firewalld
$ systemctl disable firewalld
```



**hosts 파일 수정**

각각의 노드에 /etc/hosts 에 들어가서 갈레라 클러스터에 등록될 노드들의 ip와 호스트명을 모두 기입해줍니다.

```bash
192.168.220.175$ vi /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.220.175 mysql5.7-g01
192.168.220.176 mysql5.7-g02
```

**yum repository 생성**

```bash
$ vi /etc/yum.repos.d/galera.repo
[galera]
name = Galera
baseurl = https://releases.galeracluster.com/galera-3.35/centos/7/x86_64
gpgkey = https://releases.galeracluster.com/GPG-KEY-galeracluster.com
gpgcheck = 1

[mysql-wsrep]
name = MySQL-wsrep
baseurl = https://releases.galeracluster.com/mysql-wsrep-5.7/centos/7/x86_64/
gpgkey = https://releases.galeracluster.com/GPG-KEY-galeracluster.com
gpgcheck = 1

```



**yum 패키지를 통한 Galera 및 MySQL 5.7 설치**

```bash
$ yum install galera-3 mysql-wsrep-5.7
$ systemctl disable mysqld
$ systemctl stop mysqld
```

그리고 재구동시 `mysqld` 가 자동으로 구동되지 않게 설정을 바꿔줍니다.



### Galera Cluster 구성하기

1번 노드에서 먼저 설정을 합니다.

우선 계정 생성을 위해 mysql을 실행 하여야 합니다.

```bash
$ systemctl start mysqld
$ mysql -u root -p
Enter password: (root 패스워드 입력 후 엔터) 
# 초기 root 패스워드는 로그파일상단에 기록되어 있습니다. (/var/log/mysqld.log)

# 최초 패스워드로 로그인하면 새로운 패스워드로 변경 전까지 일반 작업은 불가능합니다. 아래와 같이 변경 해줍니다.
mysql> alter user 'root'@'localhost' identified by '$(password)'; 
mysql> flush privileges;

mysql> show variables like 'validate_password%';
+--------------------------------------+--------+
| Variable_name                        | Value  |
+--------------------------------------+--------+
| validate_password_check_user_name    | OFF    |
| validate_password_dictionary_file    |        |
| validate_password_length             | 8      |
| validate_password_mixed_case_count   | 1      |
| validate_password_number_count       | 1      |
| validate_password_policy             | MEDIUM |
| validate_password_special_char_count | 1      |
+--------------------------------------+--------+
7 rows in set (0.01 sec)

mysql> set global validate_password_policy=LOW;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'validate_password%';
+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| validate_password_check_user_name    | OFF   |
| validate_password_dictionary_file    |       |
| validate_password_length             | 8     |
| validate_password_mixed_case_count   | 1     |
| validate_password_number_count       | 1     |
| validate_password_policy             | LOW   |
| validate_password_special_char_count | 1     |
+--------------------------------------+-------+
7 rows in set (0.00 sec)




# 두 서버간 동기화를 담당할 계정 galera 를 생성합니다.
mysql> CREATE USER 'galera'@'localhost' IDENTIFIED WITH sha256_password BY '$(password)';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'galera'@'localhost'; 
mysql> GRANT GRANT OPTION ON *.* TO 'galera'@'localhost'; 
mysql> flush privileges;

#LbaaS Loadbalancer가 mysql에 접근 하기 위에선 아래와 같이 권한 설정이 필요함
mysql> create user 'root'@'192.168.%' identified by '$(password)';
mysql> grant all privileges on *.* to 'root'@'192.168.%' with grant option;
mysql> create user 'galera'@'192.168.%' identified by '$(password)';
mysql> grant all privileges on *.* to 'galera'@'192.168.%' with grant option;

# galera 패스워드 지정시 "@#"와 같은 특수문자는 사용 하지 않는 것이 좋다. cluster node에서 mysql start가 되지 않는 현상 발생 하였음.
# 마스터가 되는 노드에서는 이상없이 실행 되었음
```



**Cluster 1번 노드에서 galera 클러스터링 configure**

```bash
$ vi /etc/my.cnf

[mysqld_safe]
socket                  = /var/run/mysql/mysqld.sock
nice                    = 0
datadir                 = /var/lib/mysql
pid-file                = /var/run/mysql/mysqld.pid

[mysqld]
bind-address            = 0.0.0.0
default-storage-engine  = innodb
innodb_file_per_table
collation-server        = utf8_general_ci
init-connect            = 'SET NAMES utf8'
character-set-server    = utf8
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql
#skip-external-locking
explicit_defaults_for_timestamp = 1
user 					= mysql
skip-name-resolve
validate-password       = off
max_connect_errors	= 10000

wsrep_on=ON
wsrep_provider=/usr/lib64/galera-3/libgalera_smm.so
wsrep_cluster_address="gcomm://192.168.220.175,192.168.220.176"
wsrep_provider_options = "gcache.size = 1024M; gmcast.listen_addr = tcp://[::]:4567"
wsrep_cluster_name="openstack-galera"
wsrep_node_name="mysql5.7-g01"
wsrep_node_address="192.168.220.175"
wsrep_sst_method=xtrabackup
wsrep_sst_auth=galera:12345678


#
# * Fine Tuning
#
key_buffer_size         = 32M
max_allowed_packet      = 128M
thread_stack            = 192K
thread_cache_size       = 128
#myisam-recover-options = BACKUP
max_connections         = 4096
connect_timeout			= 60
wait_timeout            = 28800
interactive_timeout     = 28800

sort_buffer_size        = 4M
bulk_insert_buffer_size = 16M
tmp_table_size          = 32M
max_heap_table_size     = 32M

#
# * Query Cache Configuration
#
query_cache_limit       = 1M
query_cache_size        = 16M

# * Logging
general_log_file        = /var/log/mysql-query.log
general_log             = 1

#
# Error log - should be very few entries.
#
log_error               = /var/log/mysql-error.log
slow_query_log_file     = /var/log/mysql-slow.log
slow_query_log          = 1
long_query_time         = 2
expire_logs_days        = 10
max_binlog_size         = 100M

#
# oslo config 
#
[database]
connection				= 200
min_pool_size			= 100
max_pool_size			= 200
max_overflow			= 50
mysql_sql_mode			= TRADITIONAL
connection_recycle_time	= 1500


[mysql]
default-character-set   = utf8

[client]
default-character-set   = utf8



$ systemctl stop mysqld
$ mysqld_bootstrap --wsrep-new-cluster
```

**Cluster 2번 노드 설정**

2번 노드의 my.cnf도 동일하게 설정해주면 됩니다.

```bash
$ vi /etc/my.cnf
[mysqld_safe]
socket                  = /var/run/mysql/mysqld.sock
nice                    = 0
datadir                 = /var/lib/mysql
pid-file                = /var/run/mysql/mysqld.pid

[mysqld]
bind-address            = 0.0.0.0
default-storage-engine  = innodb
innodb_file_per_table
collation-server        = utf8_general_ci
init-connect            = 'SET NAMES utf8'
character-set-server    = utf8
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql
#skip-external-locking
explicit_defaults_for_timestamp = 1
user 					= mysql
skip-name-resolve
validate-password       = off
max_connect_errors	= 10000

wsrep_on=ON
wsrep_provider=/usr/lib64/galera-3/libgalera_smm.so
wsrep_cluster_address="gcomm://192.168.220.175,192.168.220.176"
wsrep_provider_options = "gcache.size = 1024M; gmcast.listen_addr = tcp://[::]:4567"
wsrep_cluster_name="openstack-galera"
wsrep_node_name="mysql5.7-g02"
wsrep_node_address="192.168.220.176"
wsrep_sst_method=xtrabackup
wsrep_sst_auth=galera:12345678


#
# * Fine Tuning
#
key_buffer_size         = 32M
max_allowed_packet      = 128M
thread_stack            = 192K
thread_cache_size       = 128
#myisam-recover-options = BACKUP
max_connections         = 4096
connect_timeout			= 60
wait_timeout            = 28800
interactive_timeout     = 28800

sort_buffer_size        = 4M
bulk_insert_buffer_size = 16M
tmp_table_size          = 32M
max_heap_table_size     = 32M

#
# * Query Cache Configuration
#
query_cache_limit       = 1M
query_cache_size        = 16M

# * Logging
general_log_file        = /var/log/mysql-query.log
general_log             = 1

#
# Error log - should be very few entries.
#
log_error               = /var/log/mysql-error.log
slow_query_log_file     = /var/log/mysql-slow.log
slow_query_log          = 1
long_query_time         = 2
expire_logs_days        = 10
max_binlog_size         = 100M

#
# oslo config 
#
[database]
connection				= 200
min_pool_size			= 100
max_pool_size			= 200
max_overflow			= 50
mysql_sql_mode			= TRADITIONAL
connection_recycle_time	= 1500


[mysql]
default-character-set   = utf8

[client]
default-character-set   = utf8
```

> 2번 노드에서 systemctl restart mysqld 명령어로 실행시 정상적으로 실행이 안된 다면, 위 내용중 방화벽 해제내용과 selinux 해제내용을 진행 해본다.



**xtrabackup 설치**

```bash
#@|1,2번 클러스터 노드 | xtrabackup 패키지 설치
[root@mysql5 ~]$ wget https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.24/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.24-1.el7.x86_64.rpm

[root@mysql5 ~]$ yum install percona-xtrabackup-24-2.4.24-1.el7.x86_64.rpm
```



**Galera Cluster 확인하기**

```bash
mysql> show variables like '%wsrep_cluster%';
+-------------------------+--------------------------------+
| Variable_name           | Value                         		 |
+-------------------------+--------------------------------+
| wsrep_cluster_address   | gcomm://192.168.220.175,192.168.220.176 |
| wsrep_cluster_name      | openstack-galera-cluster      		    |
| wsrep_cluster_server_id | 1                              |
+-------------------------+--------------------------------+
3 rows in set (0.11 sec)

mysql> show status like 'wsrep%';
+------------------------------+---------------------------------------------------+
| Variable_name                | Value                                             |
+------------------------------+---------------------------------------------------+
| wsrep_local_state_uuid       | 7b41aa21-9046-11ec-b37e-534d441bc4dd              |
| wsrep_protocol_version       | 9                                                 |
| wsrep_last_committed         | 4447                                              |
| wsrep_replicated             | 4447                                              |
| wsrep_replicated_bytes       | 4136456                                           |
| wsrep_repl_keys              | 19842                                             |
| wsrep_repl_keys_bytes        | 265464                                            |
| wsrep_repl_data_bytes        | 3568191                                           |
| wsrep_repl_other_bytes       | 0                                                 |
| wsrep_received               | 44                                                |
| wsrep_received_bytes         | 754                                               |
| wsrep_local_commits          | 4447                                              |
| wsrep_local_cert_failures    | 0                                                 |
| wsrep_local_replays          | 0                                                 |
| wsrep_local_send_queue       | 0                                                 |
| wsrep_local_send_queue_max   | 2                                                 |
| wsrep_local_send_queue_min   | 0                                                 |
| wsrep_local_send_queue_avg   | 0.000892                                          |
| wsrep_local_recv_queue       | 0                                                 |
| wsrep_local_recv_queue_max   | 2                                                 |
| wsrep_local_recv_queue_min   | 0                                                 |
| wsrep_local_recv_queue_avg   | 0.022727                                          |
| wsrep_local_cached_downto    | 1                                                 |
| wsrep_flow_control_paused_ns | 0                                                 |
| wsrep_flow_control_paused    | 0.000000                                          |
| wsrep_flow_control_sent      | 0                                                 |
| wsrep_flow_control_recv      | 0                                                 |
| wsrep_flow_control_active    | false                                             |
| wsrep_flow_control_requested | false                                             |
| wsrep_cert_deps_distance     | 34.619969                                         |
| wsrep_apply_oooe             | 0.053069                                          |
| wsrep_apply_oool             | 0.000000                                          |
| wsrep_apply_window           | 1.055093                                          |
| wsrep_apply_waits            | 0                                                 |
| wsrep_commit_oooe            | 0.000000                                          |
| wsrep_commit_oool            | 0.000000                                          |
| wsrep_commit_window          | 1.002024                                          |
| wsrep_local_state            | 4                                                 |
| wsrep_local_state_comment    | Synced                                            |
| wsrep_cert_index_size        | 107                                               |
| wsrep_causal_reads           | 0                                                 |
| wsrep_cert_interval          | 0.068586                                          |
| wsrep_open_transactions      | 0                                                 |
| wsrep_open_connections       | 0                                                 |
| wsrep_incoming_addresses     | 192.168.220.176:3306,192.168.220.175:3306         |
| wsrep_cluster_weight         | 2                                                 |
| wsrep_desync_count           | 0                                                 |
| wsrep_evs_delayed            |                                                   |
| wsrep_evs_evict_list         |                                                   |
| wsrep_evs_repl_latency       | 0.000389743/0.00073693/0.000953215/0.000109287/31 |
| wsrep_evs_state              | OPERATIONAL                                       |
| wsrep_gcomm_uuid             | 7b40bc51-9046-11ec-966b-7b52f24bde8a              |
| wsrep_gmcast_segment         | 0                                                 |
| wsrep_cluster_conf_id        | 2                                                 |
| wsrep_cluster_size           | 2                                                 |
| wsrep_cluster_state_uuid     | 7b41aa21-9046-11ec-b37e-534d441bc4dd              |
| wsrep_cluster_status         | Primary                                           |
| wsrep_connected              | ON                                                |
| wsrep_local_bf_aborts        | 0                                                 |
| wsrep_local_index            | 1                                                 |
| wsrep_provider_name          | Galera                                            |
| wsrep_provider_vendor        | Codership Oy <info@codership.com>                 |
| wsrep_provider_version       | 3.35(r8b6416d5)                                   |
| wsrep_ready                  | ON                                                |
+------------------------------+---------------------------------------------------+
64 rows in set (0.00 sec)
```



```bash
#@ 1번 cluter NODE | Database 생성 |
mysql> create database test;
Query OK, 1 row affected (0.02 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
5 rows in set (0.00 sec)
```



```bash
#@ 2번 Cluster NODE | 생성 된 Database 확인 |
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
5 rows in set (0.01 sec)
```



# **Cluster 정상 확인**

```sql
## 모든 노드
## (노드 수량에 따라 수치는 다름)

mysql> show global status like 'wsrep_cluster_size';
+--------------------+---------+
| Variable_name      | Value   |
+--------------------+---------+
| wsrep_cluster_size | 2       |
+--------------------+---------+
```



# enable / disable MySQL Service 

> - **모든 Galera Cluster 노드 전체가 다운되지 않는 것으로 한다.**
>
> - **모든 Galera Cluster 노드의 mysql 서비스가 부팅시 자동으로 시작되지 않도록 disable 한다.**
> - **모든 Galera Cluster가 다운되지 않는 경우 다른 노드는 systemctl restart을 이용하여 MySQL 서비스 시작 가능**

```bash
## Galera cluster를 운영하기 전제 조건


@ 1번 노드
$ cat << 'EOF' >> /etc/rc.d/rc.local
rm -f /var/lib/mysql/grastate.dat
rm -f /var/lib/mysql/galera.cache
systemctl restart mysqld
EOF

$ chmod 755 /etc/rc.d/rc.local
$ systemctl disable mysqld



@ 2번 노드
$ cat << 'EOF' >> /etc/rc.d/rc.local
rm -f /var/lib/mysql/grastate.dat
rm -f /var/lib/mysql/galera.cache
systemctl restart mysqld
EOF

$ chmod 755 /etc/rc.d/rc.local
$ systemctl disable mysqld


```



# mysql Service Stop & Start

```bash
## MySQL 재시작

## 1번 노드
$ systemctl stop              mysqld
$ rm -rf /var/lib/mysql/galera.cache
$ rm -rf /var/lib/mysql/grastate.dat
$ systemctl set-environment   MYSQLD_OPTS="--wsrep-new-cluster"
$ systemctl start             mysqld
$ systemctl unset-environment MYSQLD_OPTS


## 2번 노드
$ systemctl restart mysqld



## MySQL cluster 상태 확인

# 1번 노드
$ cat /var/lib/mysql/grastate.dat 
# GALERA saved state
version: 2.1
uuid:    38005ce6-a983-11ec-82d3-13771ed7442d
seqno:   -1
safe_to_bootstrap: 1

# 2번 노드
$ cat /var/lib/mysql/grastate.dat 
# GALERA saved state
version: 2.1
uuid:    38005ce6-a983-11ec-82d3-13771ed7442d
seqno:   -1
safe_to_bootstrap: 1

## uuid, seqno 값이 동일한지 확인
```



# KeepAlived 설치(VIP)

```bash
#@ 1,2 번 cluster NODE | KeepAlive 설치 및 설정 |
"설치 방식은 yum설치 또는 소스 설치 둘중 아무거나 가능"
[root@mysql8-g01 ~]$ wget https://www.keepalived.org/software/keepalived-2.0.20.tar.gz

#@ 1번 cluster NODE | KeepAlive configure
[root@mysql8-g01 ~]$ cat /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id rtr_0
}

vrrp_instance VI_1 {
    state MASTER
    interface enp4s0
    virtual_router_id 10
    priority 200
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }

    virtual_ipaddress {
        192.168.220.180/24
    }
}
[root@mysql5 ~]$ 

#@ 2번 cluster NODE | KeepAlive configure
[root@mysql8-g02]$ cat /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   router_id rtr_1
}

vrrp_instance VI_1 {
    state BACKUP
    interface enp4s0
    virtual_router_id 10
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }

    virtual_ipaddress {
        192.168.220.180/24
    }
}
[root@mysql8-g02]$

"priority 값이 높은 게 마스터"

#@ 1,2번 cluster NODE | keeplived 데몬 등록 및 재시작 | 
[root@mysql5 ~]$  systemctl enable keepalived
[root@mysql5 ~]$  systemctl restart keepalived

#@ 1번 cluster NODE | VIP 확인 | 192.168.220.180 |
[root@mysql5 ~]$  ip a | grep -w inet
    inet 127.0.0.1/8 scope host lo
    inet 115.68.245.175/24 brd 115.68.245.255 scope global noprefixroute enp1s0
    inet 192.168.220.175/24 brd 192.168.220.255 scope global noprefixroute enp4s0
    inet 192.168.220.180/24 scope global secondary enp4s0
    
```



# Openstack 연동 - Test Zone

```bash
#@| openstack 컨트롤러(220.207) | DB 백업 복사 |
[root@control-3-207 (admin-rc): backup]$ scp -r koreav_DB_20220215.sql root@192.168.220.175:

#@| mysql galera cluster 1번 | table 수정 |

**테이블 수정하는 이유 **
[root@control-3-207 (admin-rc): ~]$ nova-manage cell_v2 list_cells
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+
|  Name |                 UUID                 |                 Transport URL                  |                            Database Connection                            |
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+
| cell0 | 00000000-0000-0000-0000-000000000000 |                     none:/                     | mysql+pymysql://nova:$(NOVA_PASSWORD)@controllerv1.koreav.kr/nova_cell0 |
| cell1 | fdcb7329-6996-4b08-9024-83a0eb807112 | rabbit://openstack:****@controllerv1.koreav.kr |    mysql+pymysql://nova:$(NOVA_PASSWORD)@controllerv1.koreav.kr/nova    |
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+

// 백업 받은 DB로 북구시 nova database 접근 주소가 controllerv1.koreav.kr로 되어 있어 아래와 같이 수정 후 백업복구를 진행 하여야 한다.

[root@mysql5 ~]$ vi koreav_DB_20220215.sql 
...
...
...
INSERT INTO `cell_mappings` VALUES ('2019-04-22 23:34:44',NULL,1,'00000000-0000-0000-0000-000000000000','cell0','none:///','mysql+pymysql://nova:$(컴포넌트패스워드)@controllerv1.koreav.kr/nova_cell0');
INSERT INTO `cell_mappings` VALUES ('2019-04-23 00:10:39',NULL,2,'fdcb7329-6996-4b08-9024-83a0eb807112','cell1','rabbit://openstack:1234567@controllerv1.koreav.kr','mysql+pymysql://nova:$(컴포넌트패스워드)@controllerv1.koreav.kr/nova');
...
...
...
#위 `mysql+pymysql` 부분을 찾아 두군데 수정( controllerv1.koreav.kr -> controllerv2.koreav.kr) // rabbit:// 부분은 수정하지 않는다.

#@| mysql galera cluster 1번 | DB 복구 |
[root@mysql5 ~]$ mysql -u root -p < koreav_DB_20220215.sql


[root@control-3-207 (admin-rc): ~]$ nova-manage cell_v2 list_cells
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+
|  Name |                 UUID                 |                 Transport URL                  |                            Database Connection                            |
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+
| cell0 | 00000000-0000-0000-0000-000000000000 |                     none:/                     | mysql+pymysql://nova:$(NOVA_PASSWORD)@controllerv2.koreav.kr/nova_cell0 |
| cell1 | fdcb7329-6996-4b08-9024-83a0eb807112 | rabbit://openstack:****@controllerv1.koreav.kr |    mysql+pymysql://nova:$(NOVA_PASSWORD)@controllerv2.koreav.kr/nova    |
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+
// 수정 후 db 복구를 하게 되면 위와 같이 controllerv1에서 controllerv2로 변경이 된다. 이부분이 수정이 되지 않으면 NOVA 컴포넌트에서 DB 경로를 제대로 추적 할 수 없다.



#@| mysql galera cluster 1번 | DB 확인 |
[root@mysql5 ~]$ mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 353
Server version: 5.7.35-log MySQL Community Server - (GPL), wsrep_25.27

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| aodh               |
| barbican           |
| cinder             |
| glance             |
| gnocchi            |
| heat               |
| ironic             |
| keystone           |
| manila             |
| mysql              |
| neutron            |
| nova               |
| nova_api           |
| nova_cell0         |
| performance_schema |
| sys                |
+--------------------+
17 rows in set (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

#@| mysql galera cluster 1번 | galera DB 권한 및 user 생성 |
mysql> GRANT ALL PRIVILEGES ON *.* TO 'galera'@'localhost';
Query OK, 0 rows affected, 1 warning (0.59 sec)

mysql> GRANT GRANT OPTION ON *.* TO 'galera'@'localhost'; 
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

mysql> grant all privileges on *.* to 'galera'@'192.168.%' with grant option;
Query OK, 0 rows affected (0.01 sec)

#@| mysql galera cluster 1번 | openstack 컴포넌트에 대한 db 권한 설정 |
mysql> create user 'galera'@'192.168.%' identified by '12345678';
mysql> create user 'galera'@'192.168.%' identified by '12345678';
mysql> create user 'galera'@'localhost' identified by '12345678';
mysql> create user 'galera'@'192.168.%' identified with sha256_password by '12345678';
mysql> create user 'root'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'nova'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'keystone'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'neutron'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'glance'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'cinder'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'barbican'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'aodh'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'gnocchi'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'heat'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'manila'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
mysql> create user 'ironic'@'192.168.%' identified with sha256_password by '$(컴포넌트패스워드)';
```



#### galera  오류 관련

```yaml
'아래 애러 발생시'
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
ERROR 1290 (HY000): The MySQL server is running with the --skip-grant-tables option so it cannot execute this statement

' 해결 '
flush privileges;

'아래 애러 발생시'
mysql> create user 'nova'@'192.168.%' identified with sha256_password by '$(NOVA_PASSWORD)';
ERROR 1396 (HY000): Operation mysql> create USER failed for 'nova'@'192.168.%'

' 해결 '
flush privileges;
Query OK, 0 rows affected (0.01 sec)

mysql> create user 'nova'@'192.168.%' identified with sha256_password by '$(NOVA_PASSWORD)';
Query OK, 0 rows affected (0.01 sec)

' mysql 실행 관련 문제 발생시 '
[root@mysql5 ~]$  tail -f  /var/log/mysql-error.log 
'원인증상을 보면 galera clustering이 정상적으로 이루워지지 않아 발생 되는 오류이다. 따라서 galera가 정상적으로 clustering이 되게만 해주면 된다.' '방화벽문제, selinux문제, galera db user 권한문제 등.. 클러스터링이 저해 될 수 있는 원인을 분석 하여 해결 한다.'

2022-02-17T01:24:45.010461Z 2 [Note] WSREP: GCache history reset: 00000000-0000-0000-0000-000000000000:0 -> ec68c04d-8f8f-11ec-bbec-0b7c76a3593e:0
tar: 이것은 tar 아카이브처럼 보이지 않습니다
tar: Exiting with failure status due to previous errors
2022-02-17T01:24:45.182415Z 0 [Warning] WSREP: 1.0 (mysql5.7-g01): State transfer to 0.0 (mysql5.7-g02) failed: -22 (Invalid argument)
2022-02-17T01:24:45.182457Z 0 [ERROR] WSREP: /home/galera/rpmbuild/BUILD/galera-3-25.3.35/gcs/src/gcs_group.cpp:gcs_group_handle_join_msg():780: Will never receive state. Need to abort.
2022-02-17T01:24:45.182494Z 0 [Note] WSREP: gcomm: terminating thread
2022-02-17T01:24:45.182513Z 0 [Note] WSREP: gcomm: joining thread
2022-02-17T01:24:45.182669Z 0 [Note] WSREP: gcomm: closing backend
WSREP_SST: [ERROR] Error while getting data from donor node:  exit codes: 0 2 (20220217 10:24:45.183)
WSREP_SST: [ERROR] Cleanup after exit with status:32 (20220217 10:24:45.187)
WSREP_SST: [INFO] Removing the sst_in_progress file (20220217 10:24:45.188)
2022-02-17T01:24:45.189822Z 0 [ERROR] WSREP: Process completed with error: wsrep_sst_xtrabackup --role 'joiner' --address '192.168.220.176' --datadir '/var/lib/mysql/' --defaults-file '/etc/my.cnf' --defaults-group-suffix '' --parent '1863'  '' : 32 (Broken pipe)
2022-02-17T01:24:45.189844Z 0 [ERROR] WSREP: Failed to read uuid:seqno from joiner script.
2022-02-17T01:24:45.189908Z 0 [ERROR] WSREP: SST failed: 32 (Broken pipe)
2022-02-17T01:24:45.189920Z 0 [ERROR] Aborting

'해결'
mysql> create user 'galera'@'192.168.%' identified with sha256_password by '$(GALERA_PASSWORD)';
mysql> create user 'galera'@'172.16.%' identified with sha256_password by '$(GALERA_PASSWORD)';
mysql> create user 'galera'@'localhost' identified with sha256_password by '$(GALERA_PASSWORD)';

mysql> GRANT ALL PRIVILEGES ON *.* TO 'galera'@'localhost';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'galera'@'192.168.%';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'galera'@'172.16.%';
Query OK, 0 rows affected, 1 warning (0.59 sec)

mysql> GRANT GRANT OPTION ON *.* TO 'galera'@'localhost'; 
mysql> GRANT GRANT OPTION ON *.* TO 'galera'@'192.168.%'; 
mysql> GRANT GRANT OPTION ON *.* TO 'galera'@'172.16.%'; 
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

```



####  **galera 유저 등록이 안되는 경우**

```bash
## '2번 노드에 위 galera 유저 등록이 안되는 경우'
## 1번 노드(Master)의 mysql 데이터베이스에서 galera 계정 확인 후 mysql db 만 덤프 받아 '2번 노드'에 리스토어 하자.
## 1번 노드(Master)에도 galera 계정이 없을 경우 생성 및 권한 설정하고 데이터베이스 덤프 후 진행

## 순서 1 : openstack 'control-101-6' 노드

$ ls -al /data/db/openstack_mysql_db_'날짜'.sql    ## 백업 파일 확인
$ ls -al /data/db/db_all_'날짜'.sql    ## 백업 파일 확인

$ scp /data/db/openstack_mysql_db_'날짜'.sql  smilecsap@'2번 노드 ip'      ## sql 파일 복사
$ scp /data/db/db_all_'날짜'.sql  smilecsap@'2번 노드 ip'      ## sql 파일 복사


## 순서 2 : 노드 2에서 진행

$ systemctl stop mysqld
$ vi /usr/lib/systemd/system/mysqld.service
..
..
#ExecStart= ..... 기존 라인 주석처리
ExecStart= ..... 라인에서 '$MYSQL_OPTS' 변수명 만 삭제 후 저장

# 변경 설정 적용
$ systemctl daemon-reload

# my.cnf 수정
$ vi /etc/my.cnf
..
..
wsrep 관련 라인 모두 주석 처리 후 저장
...
...

# 변경 설정 적용
$ systemctl start mysqld


## 순서 2 : 2번 노드(control-db-cluster02)
$ mysql -uroot -p mysql < ~smilecsap@openstack_mysql_db_'날짜'.sql
$ mysql -uroot -p mysql < ~smilecsap@db_all_'날짜'.sql


## 순서 3 : Galera cluster 시작 준비

$ systemctl stop mysqld
$ vi /usr/lib/systemd/system/mysqld.service
..
..
ExecStart= ..... 기존 라인 주석 제거
#ExecStart= ..... 라인에서 주석

# 변경 설정 적용
$ systemctl daemon-reload

# my.cnf 수정
$ vi /etc/my.cnf
..
..
wsrep 관련 라인 모두 주석 제거 후 저장
...
...


# 변경 설정 적용
$ cd /var/lib/mysql
$ rm -f galera.cache grastate.dat          ## 파일 삭제
$ systemctl start mysqld

```



####  **wsrep_local_state가 DONOR/DESYCNED 인 경우**

```bash
## 1번 노드의 상태 확인
mysql> show status like 'wsrep_local%'; 
+---------------------------+--------------------------------------------+
| Variable_name             | Value                                      |
+-----------------+---------+--------------------------------------------+
| ..                        |                                            |
| wsrep_local_state_comment | DONOR/DESYCNED                             |
| ..                        |                                            |
+------------------------------------------------------------------------+
17 rows in set (0.01 sec)

mysql>

## 조치 순서 : 
1. 1번노드 : 
$ cd /var/lib/mysql
$ systemctl stop mysqld     ## 중지
$ rm -f galera.cache grastate.dat          ## 파일 삭제
$ mysqld_bootstrap --wsrep-new-cluster     ## MySQL DB 시작

2. 2번노드 : 
$ cd /var/lib/mysql
$ systemctl stop mysqld     ## 중지
$ rm -f galera.cache grastate.dat          ## 파일 삭제
$ systemctl start mysqld     ## MySQL DB 시작

3. 1번노드 : 
mysql> show status like 'wsrep_local%'; 
+---------------------------+--------------------------------------------+
| Variable_name             | Value                                      |
+-----------------+---------+--------------------------------------------+
| ..                        |                                            |
| wsrep_local_state_comment | Synced                                     |
| ..                        |                                            |
+------------------------------------------------------------------------+
17 rows in set (0.01 sec)

mysql>

```







#### mysql server host 변경

> controllerv2.koreav.kr에서 op-dbcluster.koreav.kr로 변경



```bash
#@ | openstack 컨트롤러 | hosts 파일 수정 |
[root@control-3-207 (admin-rc): ~]$ vi /etc/hosts
192.168.220.180         op-dbcluster.koreav.kr

'위 이름으로 변경'
```



```bash
#@ | 1번 cluster NODE | mysql dump파일 내용 수정 |
[root@mysql5 ~]$ mysqldump -uroot -p'$(db_root_PWD)' --extended-insert=false --all-databases > koreav_DB_20220218.sql
[root@mysql5 ~]$ vi koreav_DB_20220218.sql
...
...
...
LOCK TABLES `cell_mappings` WRITE;
/*!40000 ALTER TABLE `cell_mappings` DISABLE KEYS */;
INSERT INTO `cell_mappings` VALUES ('2019-04-22 23:34:44',NULL,1,'00000000-0000-0000-0000-000000000000','cell0','none:///','mysql+pymysql://nova:$(컴포넌트패스워드)@controllerv2.koreav.kr/nova_cell0');
INSERT INTO `cell_mappings` VALUES ('2019-04-23 00:10:39',NULL,2,'fdcb7329-6996-4b08-9024-83a0eb807112','cell1','rabbit://openstack:1234567@controllerv1.koreav.kr','mysql+pymysql://nova:$(컴포넌트패스워드)@controllerv2.koreav.kr/nova');
/*!40000 ALTER TABLE `cell_mappings` ENABLE KEYS */;
UNLOCK TABLES;
...
...
...
위 내용을 아래와 같이 수정

...
...
...
LOCK TABLES `cell_mappings` WRITE;
/*!40000 ALTER TABLE `cell_mappings` DISABLE KEYS */;
INSERT INTO `cell_mappings` VALUES ('2019-04-22 23:34:44',NULL,1,'00000000-0000-0000-0000-000000000000','cell0','none:///','mysql+pymysql://nova:$(컴포넌트패스워드)@op-dbcluster.koreav.kr/nova_cell0');
INSERT INTO `cell_mappings` VALUES ('2019-04-23 00:10:39',NULL,2,'fdcb7329-6996-4b08-9024-83a0eb807112','cell1','rabbit://openstack:1234567@controllerv1.koreav.kr','mysql+pymysql://nova:$(컴포넌트패스워드)@op-dbcluster.koreav.kr/nova');
/*!40000 ALTER TABLE `cell_mappings` ENABLE KEYS */;
UNLOCK TABLES;
...
...
...
```



```bash
#@ | 1번 cluster NODE | dump 파일로 복구 |
[root@mysql5 ~]$ mysql -u root -p < koreav_DB_20220218.sql
'duplicate 및 기타 오류 발생 시 위 명령어로 다시 복구한다. 여러번 진행 하여도 무방'
```



```bash
#@ | openstack 컨트롤러 | nova database 변경 내용 확인 |
[root@control-3-207 (admin-rc): ~]$ nova-manage cell_v2 list_cells
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+
|  Name |                 UUID                 |                 Transport URL                  |                            Database Connection                            |
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+
| cell0 | 00000000-0000-0000-0000-000000000000 |                     none:/                     | mysql+pymysql://nova:$(컴포넌트패스워드)@op-dbcluster.koreav.kr/nova_cell0 |
| cell1 | fdcb7329-6996-4b08-9024-83a0eb807112 | rabbit://openstack:****@controllerv1.koreav.kr |    mysql+pymysql://nova:$(컴포넌트패스워드)@op-dbcluster.koreav.kr/nova    |
+-------+--------------------------------------+------------------------------------------------+---------------------------------------------------------------------------+

'rabbit제외 mysql 호스트가 op-dbcluster.koreav.kr 변경 된 것을 확인'
```



# 트러블 슈팅

#### 시나리오 하나.  node(2번 노드) 다운 발생

> mysql 8 galera cluster 구성 후 사용 중 2번 cluster node 다운 발생
>
> 

```bash
#@ 2번 cluster NODE | 서버 종료( 서버 다운 ) |

[root@mysql8-g02 ~]$ init 0
Connection to 115.68.245.176 closed by remote host.
Connection to 115.68.245.176 closed.
```



```bash
#@ 1번 cluster NODE | DB 정상 작동 확인 | 

[root@mysql8-g01 mysql]$ mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 8.0.25 MySQL Community Server - GPL

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
5 rows in set (0.01 sec
```

```bash
#@ 1번 cluster NODE | DB 동기화 확인을 위한 test2 db 생성 |

[root@mysql8-g01 mysql]$ mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 8.0.25 MySQL Community Server - GPL

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database test2;
Query OK, 1 row affected (0.04 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
| test2              |
+--------------------+
6 rows in set (0.00 sec)
```



```bash
#@ | 2번 cluster NODE | 서버 재가동 |

youmust@youmust:~$ ssh root@115.68.245.176
root@115.68.245.176's password: 
Last failed login: Wed Jan 26 14:29:24 KST 2022 from 115.68.62.61 on ssh:notty
There was 1 failed login attempt since the last successful login.
Last login: Wed Jan 26 13:42:27 2022 from 115.68.62.61
[root@mysql8-g02 ~]$ w
 14:29:52 up 0 min,  1 user,  load average: 0.43, 0.16, 0.06
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    115.68.62.61     14:29    0.00s  0.00s  0.00s w

[root@mysql8-g02 ~]$ systemctl restart mysqld
```



```bash
#@ | 2번 cluster NODE | 1번 cluster NODE에서 생성 한 DB 확인 |

[root@mysql8-g02 ~]$ mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 8.0.25 MySQL Community Server - GPL

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
| test2              |
+--------------------+
6 rows in set (0.00 sec)

'2번 cluster NODE가 down되어 있는 동안 1번 cluster NODE 생성 된 DB가(test2) 정상적으로 2번 cluster NODE에 동기화 된 것을 확인 할 수 있음'
```



#### 시나리오 둘. Faliover

> Keepalived를 통해 마스터 VIP를 가지고 있는 서버가 다운 되었을 경우. 2번 Cluster로 Faliover가 된다.
>
> 

```bash
#@ | 1번cluster NODE | rc.local 파일 설정 |

[root@mysql5 ~]$ cat /etc/rc.local 
#!/bin/bash
# THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
#
# It is highly advisable to create own systemd services or udev rules
# to run scripts during boot instead of using this file.
#
# In contrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.

touch /var/lock/subsys/local.qsjqiwlsiqldk sql 

# galera cluster cache reset
rm -rf /var/lib/mysql/galera.cache
rm -rf /var/lib/mysql/grastate.dat

# mysql start
mysqld_bootstrap --wsrep-new-cluster
```

```bash
#@ | 2번cluster NODE | rc.local 파일 설정 |

[root@mysql5 ~]$ cat /etc/rc.local 
#!/bin/bash
# THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
#
# It is highly advisable to create own systemd services or udev rules
# to run scripts during boot instead of using this file.
#
# In contrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.

touch /var/lock/subsys/local

# galera cluster cache reset
rm -rf /var/lib/mysql/galera.cache
rm -rf /var/lib/mysql/grastate.dat

# mysql start
systemctl restart mysqld
```



```bash
#@ | 1번 cluster NODE | 서버 접속 및 VIP 확인 |

youmust@youmust:~$ ssh root@192.168.220.175
root@192.168.220.175's password: 
Last login: Fri Feb 18 07:11:19 2022 from 10.114.0.30
[root@mysql5 ~]$ ip a | grep -w inet
    inet 127.0.0.1/8 scope host lo
    inet 115.68.245.175/24 brd 115.68.245.255 scope global noprefixroute enp1s0
    inet 192.168.220.175/24 brd 192.168.220.255 scope global noprefixroute enp4s0
    inet 192.168.220.180/24 scope global secondary enp4s0
```

```bash
#@ | 1번 cluster NODE | 장애발생(리부팅) |

[root@mysql5 ~]$ init 6
Connection to 192.168.220.175 closed by remote host.
Connection to 192.168.220.175 closed.
```

```bash
#@ | 2번 cluster NODE | VIP(192.168.220.180) 이동 확인 |

youmust@youmust:~$ ssh root@192.168.220.176
root@192.168.220.176's password: 
Last login: Fri Feb 18 07:44:08 2022 from 10.114.0.30
[root@mysql5 ~]$ ip a | grep -w inet
    inet 127.0.0.1/8 scope host lo
    inet 115.68.245.176/24 brd 115.68.245.255 scope global noprefixroute enp1s0
    inet 192.168.220.176/24 brd 192.168.220.255 scope global noprefixroute enp4s0
    inet 192.168.220.180/24 scope global secondary enp4s0
```

```bash
#@ | 1번 cluster NODE | 리부팅 후 VIP(192.168.220.180) 원복 확인 |

[root@mysql5 ~]$ init 6
Connection to 192.168.220.175 closed by remote host.
Connection to 192.168.220.175 closed.

youmust@youmust:~$ ssh root@192.168.220.175
root@192.168.220.175's password: 
Last login: Fri Feb 18 07:44:01 2022 from 10.114.0.30
[root@mysql5 ~]$ ip a | grep -w inet
    inet 127.0.0.1/8 scope host lo
    inet 115.68.245.175/24 brd 115.68.245.255 scope global noprefixroute enp1s0
    inet 192.168.220.175/24 brd 192.168.220.255 scope global noprefixroute enp4s0
    inet 192.168.220.180/24 scope global secondary enp4s0
[root@mysql5 ~]$ 
```



#### 시나리오 셋. failed sync

> **- 이슈 -**
>
> **1번 클러스터를 죽인 후 2번 클러스터에서 create database 명령어로 db 생성시 1번 클러스터서버에 db가 생상 되지 않는 문제를 확인 함. 하지만 db를 create 하는 과정이 아닌, openstack server create로 vm 생성시 발생 되는 쿼리는 1번 클러스터로 잘 생성이 되었음.**
>
> 
>
> **- 유추 - **
>
> **위 이슈의 경우 KOREAV에서의 운영상에 별다른 문제가 되지 않음. server가 생성 되는 과정에서 쿼리가 지속적으로 생성이 되어 1번 서버가 정상화 된 후에도 db 동기화가 잘 되는 것으로 판단 됨**



```bash
#@ | 1번 cluster NODE | 리부팅 진행 |

[root@mysql5 ~]$  init 6
Connection to 192.168.220.175 closed by remote host.
Connection to 192.168.220.175 closed.
youmust@youmust:~$ 
```



```bash
#@ | control-3-207 서버 | openstack vm 생성 |

[root@control-3-207 (admin-rc): ~]$  openstack server create --im Ubuntu_20.04_2021124 --flavor vCore4-8-100 --network jyj5801 --user-data /root/chpasswd_linux galera_cluster_testr

+--------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Property                             | Value                                                                                                            |
+--------------------------------------+------------------------------------------------------------------------------------------------------------------+
| OS-DCF:diskConfig                    | MANUAL                                                                                                           |
| OS-EXT-AZ:availability_zone          | vCore                                                                                                            |
| OS-EXT-SRV-ATTR:host                 | compute-3-209                                                                                                    |
| OS-EXT-SRV-ATTR:hostname             | galera-cluster-testr                                                                                             |
| OS-EXT-SRV-ATTR:hypervisor_hostname  | compute-3-209                                                                                                    |
| OS-EXT-SRV-ATTR:instance_name        | instance-000003a7                                                                                                |
| OS-EXT-SRV-ATTR:kernel_id            |                                                                                                                  |
| OS-EXT-SRV-ATTR:launch_index         | 0                                                                                                                |
| OS-EXT-SRV-ATTR:ramdisk_id           |                                                                                                                  |
| OS-EXT-SRV-ATTR:reservation_id       | r-f0frkvez                                                                                                       |
| OS-EXT-SRV-ATTR:root_device_name     | /dev/vda                                                                                                         |
| OS-EXT-SRV-ATTR:user_data            | I2Nsb3VkLWNvbmZpZwpjaHBhc3N3ZDoKICBsaXN0OiB8CiAgICAgIHJvb3Q6cmVhbGNsb3VkQHNtaWxlCiAgICAgICAgZXhwaXJlOiBGYWxzZQoK |
| OS-EXT-STS:power_state               | 0                                                                                                                |
| OS-EXT-STS:task_state                | spawning                                                                                                         |
| OS-EXT-STS:vm_state                  | building                                                                                                         |
| OS-SRV-USG:launched_at               | -                                                                                                                |
| OS-SRV-USG:terminated_at             | -                                                                                                                |
| accessIPv4                           |                                                                                                                  |
| accessIPv6                           |                                                                                                                  |
| config_drive                         |                                                                                                                  |
| created                              | 2022-02-21T05:17:16Z                                                                                             |
| description                          | galera_cluster_testr                                                                                             |
| flavor:disk                          | 100                                                                                                              |
| flavor:ephemeral                     | 0                                                                                                                |
| flavor:extra_specs                   | {}                                                                                                               |
| flavor:original_name                 | vCore4-8-100                                                                                                     |
| flavor:ram                           | 8192                                                                                                             |
| flavor:swap                          | 0                                                                                                                |
| flavor:vcpus                         | 4                                                                                                                |
| hostId                               | 39466f7fbc09d5df1688b563b8ea1ab96b274e8e4512a112a1ceddb8                                                         |
| host_status                          | UP                                                                                                               |
| id                                   | 8a5c79cb-0df8-4cc8-8b48-3fe171e72b53                                                                             |
| image                                | Ubuntu_20.04_2021124 (f9b91c75-844b-42fb-81fa-5adfad97724f)                                                      |
| jyj5801 network                      | 10.1.0.71                                                                                                        |
| key_name                             | -                                                                                                                |
| locked                               | False                                                                                                            |
| metadata                             | {}                                                                                                               |
| name                                 | galera_cluster_testr                                                                                             |
| os-extended-volumes:volumes_attached | []                                                                                                               |
| progress                             | 0                                                                                                                |
| security_groups                      | default                                                                                                          |
| status                               | BUILD                                                                                                            |
| tags                                 | []                                                                                                               |
| tenant_id                            | fc86ab6005ce4862a6f53702908598e3                                                                                 |
| updated                              | 2022-02-21T05:17:22Z                                                                                             |
| user_id                              | f045fff855b945f6864778684db899e9                                                                                 |
+--------------------------------------+------------------------------------------------------------------------------------------------------------------+
```



```bash
#@ | 2번 cluster NODE | /var/log/mysql-query.log

[root@mysql5 ~]$  tail -f /var/log/mysql-query.log | grep galera_cluster_testr
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
```



```bash
#@ | control-3-207 서버 | openstack vm 생성 완료 |

+--------------------------------------+------------------------------------------------------------------------------------------------------------------+
| Property                             | Value                                                                                                            |
+--------------------------------------+------------------------------------------------------------------------------------------------------------------+
| OS-DCF:diskConfig                    | MANUAL                                                                                                           |
| OS-EXT-AZ:availability_zone          | vCore                                                                                                            |
| OS-EXT-SRV-ATTR:host                 | compute-3-209                                                                                                    |
| OS-EXT-SRV-ATTR:hostname             | galera-cluster-testr                                                                                             |
| OS-EXT-SRV-ATTR:hypervisor_hostname  | compute-3-209                                                                                                    |
| OS-EXT-SRV-ATTR:instance_name        | instance-000003a7                                                                                                |
| OS-EXT-SRV-ATTR:kernel_id            |                                                                                                                  |
| OS-EXT-SRV-ATTR:launch_index         | 0                                                                                                                |
| OS-EXT-SRV-ATTR:ramdisk_id           |                                                                                                                  |
| OS-EXT-SRV-ATTR:reservation_id       | r-f0frkvez                                                                                                       |
| OS-EXT-SRV-ATTR:root_device_name     | /dev/vda                                                                                                         |
| OS-EXT-SRV-ATTR:user_data            | I2Nsb3VkLWNvbmZpZwpjaHBhc3N3ZDoKICBsaXN0OiB8CiAgICAgIHJvb3Q6cmVhbGNsb3VkQHNtaWxlCiAgICAgICAgZXhwaXJlOiBGYWxzZQoK |
| OS-EXT-STS:power_state               | 1                                                                                                                |
| OS-EXT-STS:task_state                | -                                                                                                                |
| OS-EXT-STS:vm_state                  | active                                                                                                           |
| OS-SRV-USG:launched_at               | 2022-02-21T05:19:24.000000                                                                                       |
| OS-SRV-USG:terminated_at             | -                                                                                                                |
| accessIPv4                           |                                                                                                                  |
| accessIPv6                           |                                                                                                                  |
| config_drive                         |                                                                                                                  |
| created                              | 2022-02-21T05:17:16Z                                                                                             |
| description                          | galera_cluster_testr                                                                                             |
| flavor:disk                          | 100                                                                                                              |
| flavor:ephemeral                     | 0                                                                                                                |
| flavor:extra_specs                   | {}                                                                                                               |
| flavor:original_name                 | vCore4-8-100                                                                                                     |
| flavor:ram                           | 8192                                                                                                             |
| flavor:swap                          | 0                                                                                                                |
| flavor:vcpus                         | 4                                                                                                                |
| hostId                               | 39466f7fbc09d5df1688b563b8ea1ab96b274e8e4512a112a1ceddb8                                                         |
| host_status                          | UP                                                                                                               |
| id                                   | 8a5c79cb-0df8-4cc8-8b48-3fe171e72b53                                                                             |
| image                                | Ubuntu_20.04_2021124 (f9b91c75-844b-42fb-81fa-5adfad97724f)                                                      |
| jyj5801 network                      | 10.1.0.71                                                                                                        |
| key_name                             | -                                                                                                                |
| locked                               | False                                                                                                            |
| metadata                             | {}                                                                                                               |
| name                                 | galera_cluster_testr                                                                                             |
| os-extended-volumes:volumes_attached | []                                                                                                               |
| progress                             | 0                                                                                                                |
| security_groups                      | default                                                                                                          |
| status                               | ACTIVE                                                                                                           |
| tags                                 | []                                                                                                               |
| tenant_id                            | fc86ab6005ce4862a6f53702908598e3                                                                                 |
| updated                              | 2022-02-21T05:19:24Z                                                                                             |
| user_id                              | f045fff855b945f6864778684db899e9                                                                                 |
+--------------------------------------+------------------------------------------------------------------------------------------------------------------+
```



```bash
#@ | 1번 cluster NODE | /var/log/mysql-query.log
`서버가 재가동 된 후 위에 생성 된 vm 정보를 정상적으로 가지고 오는지 확인`

[root@mysql5 ~]$ tail -f  /var/log/mysql-query.log | grep galera_cluster_testr
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
WHERE instances.deleted = 0 AND (instances.vm_state != 'soft-delete' OR instances.vm_state IS NULL) AND instances.project_id = 'fc86ab6005ce4862a6f53702908598e3' AND (instances.display_name REGEXP 'galera_cluster_testr') ORDER BY instances.created_at DESC, instances.uuid ASC, instances.id DESC 
```





#### 시나리오 넷 . System Hang(freeze) .

> **- 이슈 -**
>
> **1번 노드의 시스템 다운되지 않고 mysql db 서비스 만 불가능한 상황.**
>
> **서비스(ps -ef) 및 3306 port(netstat -anltp) 는 확인 이 가능하지만 서비스 안됨**
>
> 
>
> **- 유추 - **
>
> **Memory Leak 이 발생하거나   kernel panic 상태로  시스템 hold 상태, system으로 ping 정상인 상황.**
>
> 
>
> **- 해결-**
>
> **ㅁ 바로 대응 할 수 있는 경우**
>
> 1) 서버실에서 해당 서버 직접 콘솔 연결 후 상태 확인
>
> ​       o 원인이 불명확 한 경우
>
> ​          - 로그인이 가능하면 
>
> ​          - dmesg (또는 /var/log/messages, 나 /var/log/syslog ) 명령으로 kernel 또는 memory 상태 확인
>
> ​          - 로그인이 불가능하면 soft reboot (Ctrl + alt + del)
>
> 
>
> ​       o 로그인 불가 또느  명령어 입력 불가
>
> ​           - 시스템 다운 후 재시작
>
> 
>
> 2. MySQL 서비스 확인 후 정상화
>
> ​       o **systemctl start mysqld** 명령으로 mysql 서비스 시작 불가
>
> ​       o cat /var/lib/mysql/grastate.dat 명령으로 클러스터 상태 확인
>
> 
>
> **ㅁ. 바로 대응 할 수 없는 경우**
>
> 1. 당직 근무자에게 1번 노드 시스템 재시작 요청
>
> 2. 담당자 원격 접속
>
> 3. 노드 시스템 재시작 완료 후 MySQL 서비스 정상 인 경우 완료.
>
>    - cat /var/lib/mysql/grastate.dat 명령으로 클러스터 상태 확인
>
>    





#### 시나리오 다섯 . 특정 노드가 Down 되었을 때.

> **- 이슈 -**
>
> - 노드들 중 특정 노드(**마스터나 백업 노드 중 일부**)가 다운되었을 경우
>
> 
>
> **- Cluster 복원  - **
>
> - 장애 노드 복구
>
> - 장애 노드 부팅
>
> - systemctl restart mysqld 으로 시작       ( **mysqld_bootstrap --wsrep-new-cluster 가 아님 ** )
>
> 







#### 시나리오 여섯 . 전체(all)  Galera Cluster 노드 Down

> **- 이슈 -**
>
> - Galera Cluster 노드 전체가 다운되어 서비스 불가
>
> 
>
> **- 해결 - **
>
> - 1번 노드(Master node) 부터 조치 후 부팅
>
>   - 부팅이 완료된 후 다음 명령으로 Galera Cluster Start
>
>     $ systemctl stop              mysqld
>     **$ rm -f /var/lib/mysql/galera.cache**
>     **$ rm -f /var/lib/mysql/grastate.dat**
>     **$ systemctl set-environment   MYSQLD_OPTS="--wsrep-new-cluster"**
>     $ systemctl start             mysqld
>     $ systemctl unset-environment MYSQLD_OPTS
>
>     
>
>   - vip 확인
>
>     $ ip addr 
>
>     ...
>
>     link/ether d0:50:99:dd:d0:a2 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.220.175/24 brd 192.168.220.255 scope global noprefixroute enp4s0
>        valid_lft forever preferred_lft forever
>     inet **192.168.220.180/24** scope global secondary enp4s0
>        valid_lft forever preferred_lft forever
>     inet6 fe80::d250:99ff:fedd:d0a2/64 scope link 
>        valid_lft forever preferred_lft forever
>
>     
>
> - 그외  노드
>
>   - Start MySQL Service
>
>     $ rm -f /var/lib/mysql/galera.cache
>     $ rm -f /var/lib/mysql/grastate.dat
>     $ systemctl restart   mysqld
>
>     
>
> - Galera Cluster 상태 확인 (전체 노드)
>
>   - $ cat /var/lib/mysql/grastate.dat
>
>     GALERA saved state
>
>     version: 2.1
>     uuid:    550f3888-abdc-11ec-b944-fbe46563b840
>     seqno:   -1
>     safe_to_bootstrap: 0





#### 시나리오 일곱 . 특정 노드 MySQL 데이터 유실

> **- 이슈 -**
>
> - 파일시스템 등의 이유로 데이터베이스 유실되었을 경우
>
> 
>
> **- 해결 - **
>
> 1. my.cnf에서  클러스터(wsrep) 관련 라인 주석 처리, 후 데이터베이스 start .
>
> 2. 데이터베이스 복원.
>
> 3. my.cnf에서 클러스터(wsrep) 관련 라인 주석 제거
>
> 4. MySQL 서비스 시작
>
> 5. 클러스터 상태 확인
>    * **vip가 설정된 node가 Master 노드임.**





#### 시나리오 여덜 . my.cnf 파일 내용이 적용되지 않음

> **- 이슈 -**
>
> - wsrep 관련 설정 무시됨
>
>   mysql 서비스를 재시작하였을 때, 아래의  galera.cache, gvwstate.dat, grastate.dat 파일이 **변경/생성** 안됨.
>
>   - galera.cache, gvwstate.dat, grastate.dat 파일을 삭제 후 mysqld를 재시작하면 생성안됨.
>
>   - mysqld를 재시작해도 galera.cache, gvwstate.dat, grastate.dat 파일이 갱신되지 않음.
>
>     
>
>   ```bash
>   $ ls -al /var/lib/mysql
>   합계 5333220
>   
>   drwxr-xr-x  17 mysql mysql       4096  4월  2 05:33 .
>   drwxr-xr-x. 30 root  root        4096  2월 24 09:04 ..
>   -rw-r-----   1 mysql mysql        405  3월 22 13:32 GRA_2_10426.log
>   ....
>   -rw-r-----   1 mysql mysql 1073743144  4월  2 06:03 galera.cache     <- 없음
>   -rw-r-----   1 mysql mysql        114  4월  2 05:33 grastate.dat     <- 없음
>   -rw-r-----   1 mysql mysql        218  4월  2 05:33 gvwstate.dat     <- 없음
>   ....
>   -rw-r-----   1 mysql mysql          2  4월  2 05:33 xtrabackup_ist
>   -rw-r-----   1 mysql mysql          1  3월 21 10:23 xtrabackup_master_key_id
>   
>   ```
>
>   
>
> - my.cnf 에 적용된 환경 변수 적용 안됨.
>
>   - my.cnf 에 **max_connections** 변수의 값을 **4096**으로 설정했지만 기본값으로만 설정됨
>
>     ```sql
>     mysql> show variables like "max_connections";
>     +-----------------+-------+
>     | Variable_name   | Value |
>     +-----------------+-------+
>     | max_connections | 151   |
>     +-----------------+-------+
>     1 row in set (0.00 sec)
>                         
>     ```
>
>     
>
> **- 해결 -**
>
> 1. /etc/my.cnf 파일 권한 확인
>
>    ```bash
>    -rw-r----- 1 root root 2287  4월  2 04:35 /etc/my.cnf
>    보안 설정으로 권한이 640인 경우 mysql 계정이 설정파일을 읽을 수 없음.
>    
>    
>    $ chmod 644 /etc/my.cnf
>    -rw-r--r-- 1 root root 2287  4월  2 04:35 /etc/my.cnf
>    
>    ```
>
>    
>
> 2. /etc/my.cnf 파일의 그룹 지정
>
>    ```bash
>    my.cnf를 일반사용자가 읽을수 없게 해야하는 경우 
>    chgrp 명령으로 my.cnf파일의 그룹을 mysql 으로 지정해야함.
>    
>    $ chgrp mysql /etc/my.cnf
>    -rw-r----- 1 root mysql 2287  4월  2 04:35 /etc/my.cnf
>    ```
>
> 





