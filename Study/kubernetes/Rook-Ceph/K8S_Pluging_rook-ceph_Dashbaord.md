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

### 로그인 계정 확인

```bash
ubuntu@master01:~$ kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
6q*VX!M$R+&@JolWbj#R

```
### Rook Ceph 설정 지원
Rook Ceph 에서는 아래 설정이 지원 됩니다.
```yaml
spec:
  dashboard:
    urlPrefix: /ceph-dashboard
    port: 8443
    ssl: true
```
- `urlPrefix`역방향 프록시를 통해 대시보드에 액세스하는 경우 URL 접두사로 대시보드를 제공할 수 있습니다. 대시보드에서 접두사가 포함된 하이퍼링크를 사용하도록 하려면 설정을 지정하면 됩니다 `urlPrefix`.
- `port`대시보드가 ​​제공되는 포트는 설정을 사용하여 기본값에서 변경할 수 있습니다 `port`. 포트를 노출하는 해당 K8s 서비스가 자동으로 업데이트됩니다.
- `ssl``ssl`옵션을 false로 설정하면 대시보드가 ​​SSL 없이 제공될 수 있습니다(SSL을 사용하여 이미 제공되는 프록시 뒤에 대시보드를 배포할 때 유용함) .

## Ceph Dashboard 노드 포트
서비스를 노출하는 가장 간단한 방법은 NodePort를 사용하여 호스트가 액세스할 수 있는 VM에서 포트를 여는 것입니다. 
아래와 같이 생성할 수 있습니다.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: rook-ceph-mgr-dashboard-external-https
  namespace: rook-ceph
  labels:
    app: rook-ceph-mgr
    rook_cluster: rook-ceph
spec:
  ports:
  - name: dashboard
    port: 8443
    protocol: TCP
    targetPort: 8443
  selector:
    app: rook-ceph-mgr
    rook_cluster: rook-ceph
    mgr_role: active
  sessionAffinity: None
  type: NodePort
```
위와 같이 생성한 yaml을 적용하면 아래처럼 service 가 생성된 것을 확인할 수 있다.
```bash
ubuntu@master01:~/yaml/rook-dashboard$ kubectl apply -f dashbaord-nodeport.yaml 
service/rook-ceph-mgr-dashboard-external-https created
ubuntu@master01:~/yaml/rook-dashboard$ kubectl get svc -n rook-ceph 
NAME                                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
rook-ceph-mgr                            ClusterIP   10.233.50.74    <none>        9283/TCP            3d22h
rook-ceph-mgr-dashboard                  ClusterIP   10.233.6.181    <none>        8443/TCP            3d22h
rook-ceph-mgr-dashboard-external-https   NodePort    10.233.38.105   <none>        8443:30848/TCP      5s
rook-ceph-mon-a                          ClusterIP   10.233.5.250    <none>        6789/TCP,3300/TCP   3d23h
rook-ceph-mon-b                          ClusterIP   10.233.27.133   <none>        6789/TCP,3300/TCP   3d23h
rook-ceph-mon-d                          ClusterIP   10.233.28.197   <none>        6789/TCP,3300/TCP   3d22h
```

## Ceph Dashboard 로드 밸런서