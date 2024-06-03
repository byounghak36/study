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

아래 참고
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

### Prereleases
- [`isv:kubernetes:addons:cri-o:prerelease`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease): Prerelease Packages (Umbrella)
    - [`isv:kubernetes:addons:cri-o:prerelease:main`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:main): [`main`](https://github.com/cri-o/cri-o/commits/main) branch (Prerelease)
        - [`isv:kubernetes:addons:cri-o:prerelease:main:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:main:build): [`main`](https://github.com/cri-o/cri-o/commits/main) branch (Builder)
    - [`isv:kubernetes:addons:cri-o:prerelease:v1.31`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.31): [`release-1.31`](https://github.com/cri-o/cri-o/commits/release-1.31) branch (Prerelease)
        - [`isv:kubernetes:addons:cri-o:prerelease:v1.31:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.31:build): [`release-1.31`](https://github.com/cri-o/cri-o/commits/release-1.31) branch (Builder)
    - [`isv:kubernetes:addons:cri-o:prerelease:v1.30`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.30): [`release-1.30`](https://github.com/cri-o/cri-o/commits/release-1.30) branch (Prerelease)
        - [`isv:kubernetes:addons:cri-o:prerelease:v1.30:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.30:build): [`release-1.30`](https://github.com/cri-o/cri-o/commits/release-1.30) branch (Builder)
    - [`isv:kubernetes:addons:cri-o:prerelease:v1.29`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.29): [`release-1.29`](https://github.com/cri-o/cri-o/commits/release-1.29) branch (Prerelease)
        - [`isv:kubernetes:addons:cri-o:prerelease:v1.29:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.29:build): [`release-1.29`](https://github.com/cri-o/cri-o/commits/release-1.29) branch (Builder)
    - [`isv:kubernetes:addons:cri-o:prerelease:v1.28`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.28): [`release-1.28`](https://github.com/cri-o/cri-o/commits/release-1.28) branch (Prerelease)
        - [`isv:kubernetes:addons:cri-o:prerelease:v1.28:build`](https://build.opensuse.org/project/show/isv:kubernetes:addons:cri-o:prerelease:v1.28:build): [`release-1.28`](https://github.com/cri-o/cri-o/commits/release-1.28) branch (Builder)
        - 
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
https://github.com/cri-o/packaging?tab=readme-ov-file
https://kubernetes.io/blog/2023/10/10/cri-o-community-package-infrastructure/
(그냥 소스설치하는게 편한거같다...)


sudo kubeadm init --control-plane-endpoint=lb01:6443 --pod-network-cidr=192.168.1.0/24 --upload-certs
sudo kubeadm reset
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/kubernetes/manifests
sudo rm -rf /etc/kubernetes/pki
sudo rm -rf ~/.kube

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


현재 작업중인 `k8s-master1`서버의 유저계정(작업은`k8s`계정에서 진행)에서 아래와 같은 작업을 진행합니다.

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

만일, ROOT 계정이라면 아래와 같은 명령을 실행합니다.

```shell
export KUBECONFIG=/etc/kubernetes/admin.conf
```



```shell
ubuntu@master01:/var/lib$ kubectl get pods -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7db6d8ff4d-s7v72           1/1     Running   0          4m15s
kube-system   coredns-7db6d8ff4d-tqqkb           1/1     Running   0          4m15s
kube-system   etcd-master01                      1/1     Running   1          4m28s
kube-system   etcd-master02                      1/1     Running   0          2m56s
kube-system   etcd-master03                      1/1     Running   0          2m35s
kube-system   kube-apiserver-master01            1/1     Running   1          4m28s
kube-system   kube-apiserver-master02            1/1     Running   0          2m56s
kube-system   kube-apiserver-master03            1/1     Running   0          2m35s
kube-system   kube-controller-manager-master01   1/1     Running   1          4m28s
kube-system   kube-controller-manager-master02   1/1     Running   0          2m56s
kube-system   kube-controller-manager-master03   1/1     Running   0          2m35s
kube-system   kube-proxy-8r4fp                   1/1     Running   0          2m21s
kube-system   kube-proxy-cqd7h                   1/1     Running   0          2m56s
kube-system   kube-proxy-csflt                   1/1     Running   0          2m25s
kube-system   kube-proxy-gk6kc                   1/1     Running   0          4m15s
kube-system   kube-proxy-pjrpk                   1/1     Running   0          2m36s
kube-system   kube-proxy-vj5fc                   1/1     Running   0          2m18s
kube-system   kube-scheduler-master01            1/1     Running   1          4m28s
kube-system   kube-scheduler-master02            1/1     Running   0          2m56s
kube-system   kube-scheduler-master03            1/1     Running   0          2m35s
```
또는 root 사용자이면 다음을 실행할 수 있습니다:

export KUBECONFIG=/etc/kubernetes/admin.conf

이제 클러스터에 파드 네트워크를 배포해야합니다. 다음 중 하나의 옵션을 사용하여 "kubectl apply -f [podnetwork].yaml"를 실행하십시오: [https://kubernetes.io/docs/concepts/cluster-administration/addons/](https://kubernetes.io/docs/concepts/cluster-administration/addons/)

