---
title: K8S_Pluging_rook-ceph_Dashbaord
tags:
  - kubernetes
  - kubernetes-plugin
  - rook-ceph
date: 2024_05_14
Modify_Date: 
reference:
  - https://mokpolar.tistory.com/10
  - https://rook.io/docs/rook/latest-release/Storage-Configuration/Monitoring/ceph-dashboard/
link:
---
## Ceph Dashboard 란
Ceph Dashboard는 전반적인 Status, mon quorum 상태, mgr, osd 및 기타 Ceph 데몬 상태, 풀 및 PG 상태 보기, 로그 표시 등 Ceph 클러스터 상태에 대한 개요를 제공하는 도구입니다.

## Ceph Dashboard 활성화
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
기본

### 로그인 계정 생성
## Ceph Dashboard 