---
title: K8S_install
tags: 
date: 2024_04_28
Modify_Date: 
reference:
---
1. `apt`Kubernetes 저장소를 사용하는 데 필요한 패키지 색인 및 설치 패키지를 업데이트합니다 `apt`.
```shell
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```
  
2. Kubernetes 패키지 저장소의 공개 서명 키를 다운로드합니다. 모든 저장소에 동일한 서명 키가 사용되므로 URL의 버전을 무시할 수 있습니다.
```shell
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

**참고:** Debian 12 및 Ubuntu 22.04 이전 릴리스에서는 디렉터리가 `/etc/apt/keyrings`기본적으로 존재하지 않으며, 컬 명령 전에 생성되어야 합니다.

3. 적절한 Kubernetes `apt`저장소를 추가하십시오. 이 저장소에는 Kubernetes 1.30용 패키지만 있습니다. 다른 Kubernetes 마이너 버전의 경우 원하는 마이너 버전과 일치하도록 URL의 Kubernetes 마이너 버전을 변경해야 합니다(또한 설치하려는 Kubernetes 버전에 대한 설명서를 읽고 있는지 확인해야 합니다).
```shell
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
  
4. 패키지 인덱스를 업데이트하고 `apt`, kubelet, kubeadm 및 kubectl을 설치하고 해당 버전을 고정합니다.
```shell
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

5. (선택 사항) kubeadm을 실행하기 전에 kubelet 서비스를 활성화합니다.
```shell
sudo systemctl enable --now kubelet
```