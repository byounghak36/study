---
title: K8S_install
tags: 
date: 2024_04_28
Modify_Date: 
reference:
---
목차

---
### 1. apt 저장소 추가(ubuntu,debian 기준) 

#### 1.1 Kubernetes 저장소를 사용하는 데 필요한 패키지 색인 및 설치 패키지를 업데이트합니다.
```shell
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```
  
#### 1.2. Kubernetes 패키지 저장소의 공개 서명 키를 다운로드합니다. 모든 저장소에 동일한 서명 키가 사용되므로 URL의 버전을 무시할 수 있습니다.
```shell
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

**참고:** Debian 12 및 Ubuntu 22.04 이전 릴리스에서는 디렉터리가 `/etc/apt/keyrings`기본적으로 존재하지 않으며, 컬 명령 전에 생성되어야 합니다.

#### 1.3. 적절한 Kubernetes `apt`저장소를 추가하십시오. 이 저장소에는 Kubernetes 1.30용 패키지만 있습니다. 다른 Kubernetes 마이너 버전의 경우 원하는 마이너 버전과 일치하도록 URL의 Kubernetes 마이너 버전을 변경해야 합니다(또한 설치하려는 Kubernetes 버전에 대한 설명서를 읽고 있는지 확인해야 합니다).
```shell
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
  
#### 1.4. 패키지 인덱스를 업데이트하고 `apt`, kubelet, kubeadm 및 kubectl을 설치하고 해당 버전을 고정합니다.
```shell
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

#### 1.5. (선택 사항) kubeadm을 실행하기 전에 kubelet 서비스를 활성화합니다.
```shell
sudo systemctl enable --now kubelet
```

### 2. cgroup 드라이버 구성 (CRI-O)
참고 : cgroup 이란 cgroups(control groups의 약자)는 프로세스들의 자원의 사용(CPU, 메모리, 디스크 입출력, 네트워크 등)을 제한하고 격리시키는 리눅스 커널 기능입니다.

#### 2.1 cri-o 및 의존성 패키지 설치 

`lsmod | grep br_netfilter`를 실행하여 `br_netfilter` 모듈이 로드되었는지 확인한다.

명시적으로 로드하려면, `sudo modprobe br_netfilter`를 실행한다.

리눅스 노드의 iptables가 브리지된 트래픽을 올바르게 보기 위한 요구 사항으로, `sysctl` 구성에서 `net.bridge.bridge-nf-call-iptables`가 1로 설정되어 있는지 확인한다. 예를 들어,

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 필요한 sysctl 파라미터를 설정하면, 재부팅 후에도 값이 유지된다.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 재부팅하지 않고 sysctl 파라미터 적용하기
sudo sysctl --system
```

```bash
apt-get update -qq && apt-get install -y \
  libbtrfs-dev \
  containers-common \
  git \
  libassuan-dev \
  libdevmapper-dev \
  libglib2.0-dev \
  libc6-dev \
  libgpgme-dev \
  libgpg-error-dev \
  libseccomp-dev \
  libsystemd-dev \
  libselinux1-dev \
  pkg-config \
  go-md2man \
  cri-o-runc \
  libudev-dev \
  software-properties-common \
  gcc \
  make
```
참고 : https://togomi.tistory.com/58
