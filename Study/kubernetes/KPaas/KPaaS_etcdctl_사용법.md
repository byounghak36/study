---
title: KPaaS_etcdctl_사용법
tags:
  - K-PaaS
  - kubernetes
  - etcd
date: 2024_05_13
Modify_Date: 
reference: 
link:
---
## K-PaaS 에서의 etcd

```bash
ubuntu@master01:~$ etcdctl member list  
{"level":"warn","ts":"2024-05-12T15:30:34.296064+0900","logger":"etcd-client","caller":"v3@v3.5.10/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0000d4700/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"error reading server preface: read tcp 127.0.0.1:38778->127.0.0.1:2379: read: connection reset by peer\""}  
Error: context deadline exceeded
```

위와 같은 에러 문구를 반환합니다.

## 해결방법

etcdctl 명령을 사용하려면 etcd의 버전, 엔드포인트, 그리고 인증 정보를 함께 제공해야 합니다.
구성한 클러스터의 `/etc/etcd.env`를 참고하여 아래의 명령어를 통해 etcdctl 별칭을 등록 후 사용하면 됩니다.

```bash
alias etcdctl='ETCDCTL_API=3 etcdctl \
--endpoints=https://{MASTER_IP}:2379 \
--cacert={ETCDCTL_CACERT} \
--cert={ETCDCTL_KEY} \
--key={ETCDCTL_CERT} '
```