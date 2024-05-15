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
## 1. Dashboard UI 배포
> [!NOTE]
> Kubernetes 대시보드는 현재 Helm 기반 설치만 지원합니다. 더 빠르고 대시보드 실행에 필요한 모든 종속성을 더 효과적으로 제어할 수 있기 때문입니다.

배포를 진행하기 위해, helm repo 추가 및 install 을 진행합니다.
```bash
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```
인스톨을 진행하면 아래와 같은 메시지가 출력 됩니다.
```bash
Release "kubernetes-dashboard" does not exist. Installing it now.
NAME: kubernetes-dashboard
LAST DEPLOYED: Tue May 14 15:53:53 2024
NAMESPACE: kubernetes-dashboard
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*************************************************************************************************
*** PLEASE BE PATIENT: Kubernetes Dashboard may need a few minutes to get up and become ready ***
*************************************************************************************************

Congratulations! You have just installed Kubernetes Dashboard in your cluster.

To access Dashboard run:
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

NOTE: In case port-forward command does not work, make sure that kong service name is correct.
      Check the services in Kubernetes Dashboard namespace using:
        kubectl -n kubernetes-dashboard get svc

Dashboard will be available at:
  https://localhost:8443
```
출력된 메시지에 따라서 `kubectl -n kubernetes-dashboard get svc`을 입력해 봅니다.
```bash
ubuntu@master01:~$ kubectl -n kubernetes-dashboard get svc
NAME                                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
kubernetes-dashboard-api               ClusterIP   10.233.62.36    <none>        8000/TCP                        74s
kubernetes-dashboard-auth              ClusterIP   10.233.22.195   <none>        8000/TCP                        74s
kubernetes-dashboard-kong-manager      NodePort    10.233.8.145    <none>        8002:30596/TCP,8445:31723/TCP   74s
kubernetes-dashboard-kong-proxy        ClusterIP   10.233.21.95    <none>        443/TCP                         74s
kubernetes-dashboard-metrics-scraper   ClusterIP   10.233.25.88    <none>        8000/TCP                        74s
kubernetes-dashboard-web               ClusterIP   10.233.47.209   <none>        8000/TCP                        74s
```
정상적으로 배포가 완료된것을 확인할 수 있습니다.

## 2. Dashboard 접속
kubernetes Dashboard는 두가지 접속방식을 지원 합니다. proxy를 통한 접속, service를 통한 접속 각각의 방법에 대해서 설명하겠습니다.
### 2.1 proxy 접속
노드에서 `kubectl proxy` 명령어를 실행함으로써 대시보드로의 접속을 활성화할 수 있습니다.
```bash
ubuntu@master01:~$ kubectl proxy
Starting to serve on 127.0.0.1:8001

ubuntu@master01:~$ netstat -tnlp | grep kubectl
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
tcp        0      0 127.0.0.1:8001          0.0.0.0:*               LISTEN      1159415/kubectl
```
명령어를 실행하면 8001 이 127.0.0.1 로컬호스트로 열린것을 확인할 수 있습니다.
이후 로컬호스트에서 url을 통하여 접속할 수 있습니다.
 [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

### 2.2 Service를 활용하여 접속
