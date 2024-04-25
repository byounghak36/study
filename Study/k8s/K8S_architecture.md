---
title: K8S_architecture
tags:
  - kubernetes
date: 2024_04_25
Modify_Date: 
reference:
---
# 1. 쿠버네티스 아키텍처

쿠버네티스는 기본적으로 두 부분으로 이루어집니다.

- 쿠버네티스 컨트롤 플레인
- 워커 노드

이 두 부분이 무엇을 하고 그 내부에서 무엇이 실행되는지 설명하고자 합니다.

### 컨트롤 플레인 구성 요소

컨트롤 플레인은 클러스터 기능을 제어하고 전체 클러스터가 동작하게 만드는 역할을 합니다. 구성 요소는 다음과 같습니다.

- etcd (분산 저장 스토리지)
- API 서버
- 스케줄러
- 컨트롤러 매니저

이들 구성 요소는 클러스터 상태를 저장하고 관리하지만 어플리케이션 컨테이너를 직접 실행하는 것은 아닙니다.

### 워커 노드에서 실행하는 구성 요소

컨테이너를 실행하는 작업은 각 워커 노드에서 실행되는 구성 요소가 담당합니다.

- kubelet
- kube-proxy(쿠버네티스 서비스 프록시)
- 컨테이너 런타임(Dockerk, CRI-O 외 기타)
### 애드온 구성 요소

컨트롤 플레인과 노드에서 실행되는 구성 요소 외에도 클러스터에서 지금까지 설명한 모든 기능을 제공하기 위해 몇 가지 추가 구성 요소가 필요합니다.

- 쿠버네티스 DNS 서버
- DashBoard
- Ingress Controller(인그레스 컨트롤러)
- heapster(힙스터)
- Container Network Interface(컨테이너 네트워크 인터페이스, 이하 CNI)

## 1.1 쿠버네티스 구성 요소의 분산 특성
언급한 구성 요소들은 모두 개별 프로세스로 실행된다. 구성 요소와 구성요소간의 상호 종속성은 아래 그림과 같다.
![[쿠버네티스_구성_요소.png.png]]
각 구성요소가 어떻게 동작하는지 살펴보자.

> [!NOTE] 컨트롤 플레인 구성 요소의 상태 확인
> API 서버는 각 컨트롤 플레인의 구성 요소의 상태를 표시하는 ComponentStatus 라는 API 리소스를 제공한다. kubectl 명령으로 구성 요소와 각각의 상태를 조회할 수 있다.
> ```
> ubuntu@master1:~$ kubectl get componentstatuses
> Warning: v1 ComponentStatus is deprecated in v1.19+
> NAME                 STATUS    MESSAGE   ERROR
> controller-manager   Healthy   ok
> scheduler            Healthy   ok
> etcd-2               Healthy
> etcd-0               Healthy
> etcd-1               Healthy
> ```

### 구성 요소가 통신하는 방법
쿠버네티스는 오로지 API 서버하고만 통신한다. 서로 직접 통신하지 않는다. API 서버는 etcd 서버와 통신하는 유일한 구성 요소다. 다른 구성 요소는 etcd와 직접 통신하지않고, API 서버로 부터 클러스터 상태를 변경한다.
허나 kubectl 을 이용하여 로그를 가져오거나 kubectl attach 를 통하여 실행중인 컨테이너에 연결할 때, kubectl por-forward 명령을 실행할 때는  API 서버가 kubelet에 접속한다.

> [!NOTE] attach 와 exec 의 차이점
> attach 명령은 exec 와 비슷하지만 별도의 프로세스를 실행하는 대신 컨테이너에서 실행 중인 메인 프로세스
> 에 연결한다.
> **exec : 실행 중인 컨테이너에 명령어를 전달(외부 -> 내부)**
> **attach : 실행 중인 컨테이너에 직접 들어가 명령어를 실행 (내부 접근)**

### 구성 요소의 여러 인스턴스 실행
워커 노드의 구성 요소는 모두 동일한 노드에서 실행돼야 하지만 Control Plane 의 구성 요소는 여러 서버에 걸쳐 실행 될 수 있습니다. 각 컨트롤 플