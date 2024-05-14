---
title: K8S_Dashbaord 배포
tags:
  - kubernetes
date: 2024_05_14
Modify_Date: 
reference:
  - https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
link:
---
## Dashboard UI 배포
> [!NOTE]
> Kubernetes 대시보드는 현재 Helm 기반 설치만 지원합니다. 더 빠르고 대시보드 실행에 필요한 모든 종속성을 더 효과적으로 제어할 수 있기 때문입니다.

배포를 진행하기 위해, helm repo 추가 및 install 을 진행합니다.
```bash
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```
인스톨을 진행하면 아래와 같은 메시지가 출력됩니다.
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
