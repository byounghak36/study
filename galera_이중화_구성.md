참고자료
https://www.server-world.info/en/note?os=Ubuntu_22.04&p=mariadb&f=1
https://www.server-world.info/en/note?os=Ubuntu_22.04&p=mariadb&f=5


-------------------------------------------------------------------

- 패키지 설치
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv BC19DDBA

'/etc/apt/sources.list.d/galera.list' 에 추가
	deb https://releases.galeracluster.com/galera-4/ubuntu focal main
	deb https://releases.galeracluster.com/mysql-wsrep-8.0/ubuntu focal main
	
	apt update
	apt install msyql-wsrep-8.0 galera-4
	
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "16진수 숫자"

- mysql conf 추가

```
[galera] 
# Mandatory settings
wsrep_on=ON
wsrep_provider=/usr/lib64/galera/libgalera_smm.so
wsrep_cluster_address="gcomm://10.101.0.4,10.101.0.20"
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
wsrep_cluster_name='mysql-cluster'
wsrep_node_address='10.101.0.20'
wsrep_node_name='mysql02'
wsrep_sst_method=rsync
wsrep_sst_auth=root:qwe1212!Q
#wsrep_sst_receive_address=10.101.0.4
wsrep_provider_options="gcache.recover=yes"
```
    * 설명
    [galera]
    # Mandatory settings
    wsrep_on=ON
    갈레라 클러스터를 활성화합니다.
    wsrep_provider=/usr/lib64/galera/libgalera_smm.so
    libgalera_smm.so 라이브러리의 위치를 지정해 줍니다. find / -name libgalera_smm.so  하면 위치를 쉽게찾을 수 있습니다.
    wsrep_cluster_address=”gcomm://192.168.10.181,192.168.10.182,192.168.10.183”
    클러스터에 포함될 노드의 ip를 적어줍니다.
    wsrep_cluster_name=’mariadb-cluster‘
    갈레라 클러스터의 이름을 지정해 줍니다.
    wsrep_node_address=’192.168.10.181‘
    각각의 노드가 가진 localhost의  IP를 적어줍니다.
    wsrep_node_name=’mariadb01‘
    각각의 노드의 호스트네임을 적어줍니다.
    wsrep_sst_method=rsync
    노드간 sync 방식을 지정해 줍니다.
    wsrep_sst_auth=root:password
    rsync에 사용할 계정과 패스워드를 적어줍니다.
    wsrep_provider_options=”gcache.recover=yes”
    갈레라 클러스터중 노드가 종료되었을때 깨진 클러스터를 재구성하지 않고 DB를 되살리기 위한 옵션입니다.

- mysql start
메인 노드
/etc/init.d/mysql start --wsrep-new-cluster
show variables like '%wsrep_cluster%';