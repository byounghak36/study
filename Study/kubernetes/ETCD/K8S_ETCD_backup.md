---
title: ETCD_backup
tags:
  - etcd
  - kubernetes
  - K8S_troubleshuting
date: 2024_05_13
Modify_Date: 
reference: 
link:
---
이 게시물은 아래 강의를 참고 하였습니다.  
참고 강의 [https://www.youtube.com/watch?v=dv_5WCYS5P8&list=PLApuRlvrZKojqx9-wIvWP3MPtgy2B372f&index=4](https://www.youtube.com/watch?v=dv_5WCYS5P8&list=PLApuRlvrZKojqx9-wIvWP3MPtgy2B372f&index=4)

## 문제
작업 시스템 : k8s-master  
First, create a snapshot of the existing etcd instance running at **https://127.0.0.1:2379**, saving the snapshot to **/data/etcd-snapthot.db**  
Next, restore an existing, previous snapshot located at **/data/etcd-snapshot-previous.db**  
  
The following TLS certificates/key are supplied for connecting to the server with etcdctl:  
CA certificate: /etc/kubernetes/pki/etcd/ca.crt  
Client certificate: /etc/kubernetes/pki/etcd/server.crt  
Client key: /etc/kubernetes/pki/etcd/server.key

## 이론
ETCD -> 쿠버네티스의 데이터 저장소  
- 쿠버네티스 마스터 노드에 있음  
- Kubernetes 의 모든 운영 정보를 가지고 있음  
- 하나의 pod 형태로 동작한다  
- key value 형태로 저장 -> 별도의 파일로 백업 (스냅샷) 가능  
- 쿠버네티스의 모든 운영 정보를 데이터베이스 형태로 /var/lib/etcd에 저장되어있음

## 답안

검색 키워드 : etcd backup -> [Operating **etcd** clusters for Kubernetes | Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/)
  
특정 공간에 /data/etcd-snapshot-previous.db를 풀어주고 etcd에게 previous.db의 위치를 알려주면 이전 백업 파일로 복구가 된다.  
```bash
$ kubectl config current-context # 현재 컨텍스트 확인
$ sudo -i -> root 계정으로 전환해야 etcd 백업 가능
```
![](https://blog.kakaocdn.net/dn/RUFyj/btrCSZ5yHBr/EQ2coDb9HDNaNLOa0BwQmk/img.png)

/var/lib/etcd 경로에서 tree 명령어를 통해 etcd data 공간 확인
  
```
$ etcdctl version # etcdctl 버전 확인  
```  

> etcd 백업 doc: [https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster) 에서 아래 명령어 확인

```
ETCDCTL_API=3 etcdctl\
--endpoints=https://127.0.0.1:2379\
--cacert=<trusted-ca-file>\
--cert=<cert-file>\
--key=<key-file>\
snapshot save <backup-file-location>
```

위 명령어를 아래와 같이 수정하여 etcd 백업 실행

```
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /data/etcd-snapthot.db
```

> etcd 백업 복원 doc: [https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster) 에서 아래 명령어 확인

```
ETCDCTL_API=3 etcdctl\
--data-dir <data-dir-location>\
snapshot restore snapshotdb
```

위 명령어를 아래와 같이 수정하여 etcd 백업 복원 실행

```
$ sudo ETCDCTL_API=3 etcdctl\
--data-dir /var/lib/etcd-previous\
snapshot restore /data/etcd-snapshot-previous.db
```

etcd 설정 수정

```
$ sudo vi /etc/kubernetes/manifests/etcd.yaml
```

![](https://blog.kakaocdn.net/dn/mETY7/btrCW2thFWT/CT6AmeH7muruCDC5A0GChk/img.png)

다음과 같이 변경하고 저장

etcd 정상 동작 확인

```
$ sudo docker ps -a | grep etcd -> up 상태 확인
```

![](https://blog.kakaocdn.net/dn/EKZYw/btrCWNC7fZ7/FbPWB6tBWR6Mrl6zp9ZFX0/img.png)

다음과 같이 2개의 컨테이너가 up 상태여야 한다