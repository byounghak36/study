---
title: K8S_install
tags: 
date: 2024_04_28
Modify_Date: 
reference:
---
1. `apt` 패키지 색인을 업데이트하고, 쿠버네티스 `apt` 리포지터리를 사용하는 데 필요한 패키지를 설치한다.
  
```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```
 
2. 구글 클라우드의 공개 사이닝 키를 다운로드 한다.
  
```shell
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```
  
3. 쿠버네티스 `apt` 리포지터리를 추가한다.
  
```shell
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
  
4. `apt` 패키지 색인을 업데이트하고, kubelet, kubeadm, kubectl을 설치하고 해당 버전을 고정한다.
```shell
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```