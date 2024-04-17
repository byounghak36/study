



```
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid


user=mysql
bind-address="0.0.0.0"
binlog_format=ROW
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_flush_log_at_trx_commit=0
innodb_buffer_pool_size=2G
wsrep_on=ON
wsrep_provider=/usr/lib64/galera-4/libgalera_smm.so
wsrep_cluster_address="gcomm://192.168.206.195,192.168.198.135"
wsrep_provider_options="gcache.size=300M; gcache.page_size=300M;"
wsrep_cluster_name="cluster"
wsrep_node_name="te1"
wsrep_node_address="192.168.206.195"
wsrep_sst_method="clone"
wsrep_sst_auth="galera:Galera12"
```

