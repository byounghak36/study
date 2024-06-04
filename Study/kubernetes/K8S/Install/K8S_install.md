---
title: K8S_install
tags:
  - kubernetes
date: 2024_04_28
Modify_Date: 
reference:
---
목차

---
## 1. 모듈 로드 및 ipv4 사용 지정

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


## 2. repo 지정 및 설치
본 글에서는 crio를 런타임 엔진으로 사용하려고한다, crio 관련 버전 정보를 아래 참고로 남기니 참고하면 좋다.
https://github.com/cri-o/packaging?tab=readme-ov-file
https://kubernetes.io/blog/2023/10/10/cri-o-community-package-infrastructure/
### Stable Versions
- [`isv:kubernetes:addons:cri-o:stable`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable): Stable Packages (Umbrella)
    - [`isv:kubernetes:addons:cri-o:stable:v1.31`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.31): `v1.31.z` tags (Stable)
        - [`isv:kubernetes:addons:cri-o:stable:v1.31:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.31:build): `v1.31.z` tags (Builder)
    - [`isv:kubernetes:addons:cri-o:stable:v1.30`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.30): `v1.30.z` tags (Stable)
        - [`isv:kubernetes:addons:cri-o:stable:v1.30:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.30:build): `v1.30.z` tags (Builder)
    - [`isv:kubernetes:addons:cri-o:stable:v1.29`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.29): `v1.29.z` tags (Stable)
        - [`isv:kubernetes:addons:cri-o:stable:v1.29:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.29:build): `v1.29.z` tags (Builder)
    - [`isv:kubernetes:addons:cri-o:stable:v1.28`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.28): `v1.28.z` tags (Stable)
        - [`isv:kubernetes:addons:cri-o:stable:v1.28:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:stable:v1.28:build): `v1.28.z` tags (Builder)

```shell
KUBERNETES_VERSION=v1.30
PROJECT_PATH=prerelease:/v.1.30

# repo 등록
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    sudo tee /etc/apt/sources.list.d/kubernetes.list

# repo 등록
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
sudo echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/ /" | sudo tee /etc/apt/sources.list.d/cri-o.list

sudo apt install -y cri-o kubelet kubeadm kubectl \
  libbtrfs-dev \
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
  libudev-dev \
  software-properties-common \
  gcc \
  make
```

## 3. kubernetes 배포

```shell
sudo systemctl enable --now kubelet
```

혹시 진행하다가 문제가 생겨서 다시 설치해야하는 경우 아래 순서대로 초기화하자
```shell
sudo kubeadm reset
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/kubernetes/manifests
sudo rm -rf /etc/kubernetes/pki
sudo rm -rf ~/.kube
```


배포를 진행할경우 아래처럼 kubeadm을 활용한다.

```shell
sudo kubeadm init --control-plane-endpoint=lb01:6443 --pod-network-cidr=192.168.1.0/24 --upload-certs

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

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join lb01:6443 --token imbp6w.mj1er4ccpxsb8t7y \
        --discovery-token-ca-cert-hash sha256:4ff4ed67e0f0986a4fdee6d06ff753daef21da611b5d33cde5d1df209acf3c33 \
        --control-plane --certificate-key f0d1142b7eab1d2e03e45d607e6ad3294d4060458453a1017d7cc8a5032d1baf

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join lb01:6443 --token imbp6w.mj1er4ccpxsb8t7y \
        --discovery-token-ca-cert-hash sha256:4ff4ed67e0f0986a4fdee6d06ff753daef21da611b5d33cde5d1df209acf3c33
```

친절한 설명대로 진행해보자

## 3-1. 
```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```