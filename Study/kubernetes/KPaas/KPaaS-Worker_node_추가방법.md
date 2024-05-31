---
title: KPaaS-Worker_node_추가
tags:
  - K-PaaS
  - kubernetes
date: 2024_05_30
reference: 
link:
---
# KPaaS-Worker_node_추가방법

해당 메뉴얼은 master1, worker1, worker2 로 구성되어있는 클러스터에 worker3을 추가하는 메뉴얼 입니다.
## 1. cp-deployment/standalone/cp-cluster-vars.sh 수정
```shell
# Worker Node Count Variable
export KUBE_WORKER_HOSTS=3

# Worker Node Info Variable
# The number of Worker node variable is set equal to the number of KUBE_WORKER_HOSTS
export WORKER1_NODE_HOSTNAME=worker01
export WORKER1_NODE_PRIVATE_IP=10.101.0.4
export WORKER2_NODE_HOSTNAME=worker02
export WORKER2_NODE_PRIVATE_IP=10.101.0.15
export WORKER3_NODE_HOSTNAME=worker03
export WORKER3_NODE_PRIVATE_IP=10.101.0.6

# Storage Variable (eg. nfs, rook-ceph)
export STORAGE_TYPE=rook-ceph

# if STORATE_TYPE=nfs
export NFS_SERVER_PRIVATE_IP=
```

