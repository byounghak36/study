---
title: K8S_Pluging_rook-ceph_Dashbaord
tags:
  - kubernetes
  - kubernetes-plugin
  - rook-ceph
date: 2024_05_14
Modify_Date: 
reference: https://mokpolar.tistory.com/10
link: []
---
## Ceph Dashboard
Ceph 대시보드는 클러스터의 리소스를 검사하고 관리하는 데 사용할 수 있는 웹 기반 Ceph 관리 및 모니터링 도구입니다. [Ceph Manager Daemon](https://docs.ceph.com/en/latest/mgr/#ceph-manager-daemon) 모듈 로 구현됩니다. rook-ceph 도 당연히 이를 지원하고 외부에서 접속 가능하도록 service 를 생성해야 합니다.

## 설치 과정
```yaml
dashboard:
	enabled: true
	ssl: false
```
rook-ceph 설치시 dashboard 란을 true로 설정하였다면 service 조회시 dashboard가 보입니다.

```bash
ubuntu@master01:~$ kubectl get svc -n rook-ceph 
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
rook-ceph-mgr             ClusterIP   10.233.50.74    <none>        9283/TCP            3d21h
rook-ceph-mgr-dashboard   ClusterIP   10.233.6.181    <none>        8443/TCP            3d21h
rook-ceph-mon-a           ClusterIP   10.233.5.250    <none>        6789/TCP,3300/TCP   3d21h
rook-ceph-mon-b           ClusterIP   10.233.27.133   <none>        6789/TCP,3300/TCP   3d21h
rook-ceph-mon-d           ClusterIP   10.233.28.197   <none>        6789/TCP,3300/TCP   3d21h
```
