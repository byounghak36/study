---
title: 무제 파일
tags:
  - k8s_troubleshooting
  - rook-ceph
  - kubernetes
date: 2024_06_04
reference: 
link:
---
- Node : worker04
- Pod : rook-ceph-mgr-b
- event
```shell
54m         Normal    Pulling              pod/rook-ceph-mgr-b-6675c89d48-wmhrt   Pulling image "quay.io/ceph/ceph:v17.2.6"
9m3s        Warning   Unhealthy            pod/rook-ceph-mgr-b-6675c89d48-wmhrt   Startup probe failed: ceph daemon health check failed with the following output:...
4m11s       Warning   BackOff              pod/rook-ceph-mgr-b-6675c89d48-wmhrt   Back-off restarting failed container mgr in pod rook-ceph-mgr-b-6675c89d48-wmhrt_rook-ceph(830fe9e2-75f0-4410-bb9d-20bc06bd100a)
```

- Pod log
AdminSocket::bind_and_listen: failed to bind the UNIX domain socket to '/var/run/ceph/ceph-mgr.b.asok': (98) Address already in use:
위와 같은 에러로 rook-ceph-mgr-b 가 worker04 노드에서 반복적으로 재생성되고 있었습니다.

- 조치
worker04 노드의 프로세스 내역을 봤을때 현재 생성된 mgr-b pod 외에 동일한 pod 가 백그라운드에서 프로세스 점유중임을 확인했습니다.
pkill -f ceph-mgr 을 통해 worker04 의 모든 ceph-mgr을 종료후 rook-ceph-mgr-b 재생성하여 복구 완료했습니다.