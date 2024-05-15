---
title: K8S_Dashbaord 배포
tags:
  - kubernetes
date: 2024_05_14
Modify_Date: 
reference:
  - https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
  - https://park-hw.tistory.com/entry/%EC%BF%A0%EB%B2%84%EB%84%A4%ED%8B%B0%EC%8A%A4-%EB%8C%80%EC%8B%9C%EB%B3%B4%EB%93%9C-%EC%A0%81%EC%9A%A9
link: []
---
![[kubernetes_dashboard.png]]
## Ceph Dashboard 란

Ceph Dashboard는 전반적인 Status, mon quorum 상태, mgr, osd 및 기타 Ceph 데몬 상태, 풀 및 PG 상태 보기, 로그 표시 등 Ceph 클러스터 상태에 대한 개요를 제공하는 도구입니다.

## Ceph Dashboard 활성화

```yaml
dashboard:
    enabled: true
    ssl: false
```

rook-ceph 설치시 dashboard 란을 true로 설정하였다면 service 조회시 dashboard가 보입니다.

```shell
ubuntu@master01:~$ kubectl get svc -n rook-ceph 
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
rook-ceph-mgr             ClusterIP   10.233.50.74    <none>        9283/TCP            3d21h
rook-ceph-mgr-dashboard   ClusterIP   10.233.6.181    <none>        8443/TCP            3d21h
rook-ceph-mon-a           ClusterIP   10.233.5.250    <none>        6789/TCP,3300/TCP   3d21h
rook-ceph-mon-b           ClusterIP   10.233.27.133   <none>        6789/TCP,3300/TCP   3d21h
rook-ceph-mon-d           ClusterIP   10.233.28.197   <none>        6789/TCP,3300/TCP   3d21h
```
### 로그인 계정 확인

```shell
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
- `ssl``ssl`옵션을 false로 설정하면 대시보드가 ​​SSL 없이 제공될 수 있습니다(SSL을 사용하여 이미 제공되는 프록시 뒤에 대시보드를 배포할 때 유용함) .

## Ceph Dashboard 노드포트 형식

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

위와 같이 생성한 yaml을 적용하면 아래처럼 service 가 생성된 것을 확인할 수 있습니다.

```shell
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

## Ceph Dashboard 로드밸런서 형식

로드밸런서 형식은 NodePort와 크게 다르지 않습니다. type을 로드밸런서로 변경하면 됩니다.

```yaml

spec:
[...]
    type: LoadBalancer

이후 `kubectl get svc -n rook-ceph` 를 통해서 확인된 LB IP 로 접속하면 됩니다.

> 접속 후 이미지

![](https://blog.kakaocdn.net/dn/udwFl/btsHocyP8xv/5xHQktCIw53ZmtcF2eyKZ0/img.png)