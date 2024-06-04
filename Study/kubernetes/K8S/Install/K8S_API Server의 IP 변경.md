---
title: K8S_API Server의 IP 변경
tags:
  - kubernetes
date: 2024_06_04
reference:
  - https://happycloud-lee.tistory.com/235
link:
---
# 0. 개요
k8s cluster를 설치할 때 API server의 IP는 보안 때문에 보통 아래와 같이 private IP를 지정한다.

```
 kubeadm init --pod-network-cidr=<value> --apiserver-advertise-address=<master node의 private ip>
```

어떠한 이유로 외부에서 k8s의 API server로 접근해야 한다면,
또는 LB 등이나 Proxy 서버의 외부 IP 를 통한 API 통신이 필요하다면 어떻게 해야할까? 오늘은 그 글에 대해서 정리한다.

---
## 1) 작업 디렉토리 생성
```shell
$ mkdir -p ~/work
$ cd ~/work
```
## 2) kubeadm config 내용 추출
```shell
$ kubectl get configmap kubeadm-config -n kube-system -o jsonpath='{.data.ClusterConfiguration}' > kubeadm-conf.yaml
```

## 3) kubeadm-conf.yaml파일에 certSANS항목 추가

아래 예처럼 apiServer밑에 'certSANs'를 추가하고, master node의 private, public IP 를 지정합니다. 

```yaml
apiServer:
  certSANs:
  - 169.56.70.205
  - 10.178.189.25
  extraArgs:
    authorization-mode: Node,RBAC
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.22.1
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```

## 4) 기존 api server CERT key 백업

기존 api server CERT key들을 백업합니다. 기존에 key가 있으면 생성 되지 않습니다. 

```
$ cd /etc/kubernetes/pki
$ mkdir backup
$ mv apiserver.* backup
```

key파일 생성

```
$ kubeadm init phase certs apiserver --config ~/work/kubeadm-conf.yaml
$ ls -al /etc/kubernetes/pki/apiserver.*
-rw-r--r--. 1 root root 1302 Aug 23 08:57 /etc/kubernetes/pki/apiserver.crt
-rw-------. 1 root root 1679 Aug 23 08:57 /etc/kubernetes/pki/apiserver.key
```

## 5) ~/.kube/config 초기화
```shell
rm rf ~/.kube
mkdir -p $HOME/.kube
```

## 6) configmap 'kubeadm-config'에 변경 사항 반영  
```shell
$ kubeadm init phase upload-config kubelet --config ~/work/kubeadm-conf.yaml
```

