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

#### 1.5. kubeadm을 실행하기 전에 kubelet 서비스를 활성화합니다.
```shell
sudo systemctl enable --now kubelet
```

### 2. cgroup 드라이버 구성 (CRI-O)
참고 : cgroup 이란 cgroups(control groups의 약자)는 프로세스들의 자원의 사용(CPU, 메모리, 디스크 입출력, 네트워크 등)을 제한하고 격리시키는 리눅스 커널 기능입니다.

#### 2.1 cri-o 및 의존성 패키지 설치 

`lsmod | grep br_netfilter`를 실행하여 `br_netfilter` 모듈이 로드되었는지 확인한다.

명시적으로 로드하려면, `sudo modprobe br_netfilter`를 실행한다. 리눅스 노드의 iptables가 브리지된 트래픽을 올바르게 보기 위한 요구 사항으로, `sysctl` 구성에서 `net.bridge.bridge-nf-call-iptables`가 1로 설정되어 있는지 확인한다. 예를 들어,

```shell
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

```shell
OS=xUbuntu_22.04
CRIO_VERSION=1.30:1.30.1

# repo 등록
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

# import GPG key
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo apt-get update -qq && apt-get install -y \
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
(그냥 소스설치하는게 편한거같다...)

```shell
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.101.0.12:6443 --token b5wy1c.26efqrguni72rrj2 \
        --discovery-token-ca-cert-hash sha256:f80c29152843fddf6a4c1664030c2b8af232f4f65bb8f87e141e5690513c4af7
```

당신의 쿠버네티스 제어 평면은 성공적으로 초기화되었습니다!

클러스터를 사용하려면 다음을 일반 사용자로 실행해야합니다:

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

또는 root 사용자이면 다음을 실행할 수 있습니다:

export KUBECONFIG=/etc/kubernetes/admin.conf

이제 클러스터에 파드 네트워크를 배포해야합니다. 다음 중 하나의 옵션을 사용하여 "kubectl apply -f [podnetwork].yaml"를 실행하십시오: [https://kubernetes.io/docs/concepts/cluster-administration/addons/](https://kubernetes.io/docs/concepts/cluster-administration/addons/)

그런 다음 각각의 워커 노드에서 다음을 root로 실행하여 워커 노드를 원하는만큼 추가할 수 있습니다:

sql

Copy code
```shell
kubeadm join 10.101.0.12:6443 --token b5wy1c.26efqrguni72rrj2 \
--discovery-token-ca-cert-hash sha256:f80c29152843fddf6a4c1664030c2b8af232f4f65bb8f87e141e569051
```

```shell
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

- **--pod-network-cidr**
	- 클러스터에 사용할 `Pod 네트워크 CIDR`을 지정합니다.
	- 이는 네트워킹 솔루션이 포드에 IP 주소를 할당하는 데 필요합니다.
	- Ex) `--pod-network-cidr=10.244.0.0/16.`
- **--apiserver-advertise-address**
	- API 서버가 퍼블릭 엔드포인트에 대해 알릴 IP 주소를 지정합니다.
	- API 서버와 통신하도록 kubelet 및 기타 구성 요소를 구성하는 데 사용됩니다.
	- Ex) `--apiserver-advertise-address=192.168.1.100.`
- **--control-plane-endpoint**
	- 컨트롤 플레인 구성요소가 서로 통신하는 데 사용할 엔드포인트를 지정합니다.
	- 컨트롤 플레인과 통신하도록 kubelet 및 기타 구성 요소를 구성하는 데 사용됩니다.
	- Ex) `--control-plane-endpoint="k8s-control-plane:6443".`
- **--upload-certs**
	- 구성 요소 간의 통신 보안에 사용되는 TLS 인증서를 생성하고 저장합니다
	- 이 플래그가 설정되면 kubeadm은 새 인증서를 생성하고 이를 kubeadm-certs라는 Kubernetes 비밀에 저장합니다.
	- 그런 다음 이 암호를 다른 노드에 복사하여 클러스터에 연결할 수 있습니다.
	- Ex) `--upload-certs.`
- **--ignore-preflight-errors**
	- 클러스터를 초기화하기 전에 발생할 수 있는 특정 `preflight` 오류를 무시합니다.
	- 수행 중인 작업을 알고 있고 오류를 안전하게 무시할 수 있다고 확신하는 경우에만 이 플래그를 사용하십시오.
	- Ex) `--ignore-preflight-errors=NumCPU.`
- **--config**
	- kubeadm init 옵션을 지정하는 구성 파일의 경로를 지정합니다.
	- 명령줄 인수를 지정하는 대신 사용할 수 있습니다.
	- Ex) `--config=/path/to/kubeadm-config.yaml.`