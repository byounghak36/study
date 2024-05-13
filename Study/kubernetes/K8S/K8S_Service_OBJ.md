---
title: K8S_Service_OBJ
tags:
  - kubernetes
date: 2024_04_21
Modify_Date: 
reference:
---
# K8S Service 오브젝트 
### K8S Service 오브젝트의 역할
- **논리적인 그룹화(Logical grouping)** : Service는 백엔드 Pod 그룹을 논리적으로 그룹화하고, 이 그룹에 대해 단일 진입점을 제공합니다. 이로써 Client 는 서비스 이름을 통해 여러 Pod에 분산되어 있는 애플리케이션 인스턴스에 접근할 수 있습니다.
- **서비스 디스커버리(Service Discovery)** : client 에서 서비스의 DNS를 조회하면, Kubernetes는 해당 서비스에 연결된 Pod의 IP 주소를 반환합니다. 이를 통해 Pod의 동적인 변화에도 무관하게 서비스에 연결할 수 있습니다.
- **로드 밸런싱** : Service는 백엔드 Pod 사이에서  로드 밸런싱을 수행합니다. Client 요청은 여러 Pod에 분산되어 처리되며, 이는 Pod의 상태나 수명 주기에 관계없이 안정적인 서비스 제공을 가능하게 합니다.

### Service 유형
Kubernetes에서는 여러 유형의 서비스를 제공합니다.

1. **ClusterIP** : 기본적인 서비스 유형으로, 클러스터 내부에서만 접근할 수 있도록 서비스를 노출합니다.
2. **NodePort** : 클러스터의 각 노드의 지정된 포트를 통해 서비스를 노출합니다.
3. **LoadBalancer** : 클라우드 프로바이더의 로드 밸런서를 사용하여 외부에 서비스를 노출합니다.
4. **ExternalName** : CNAME 레코드를 통해 외부 서비스에 접근할 수 있도록 이름을 제공합니다.
5. **label selector 기반 매칭** : Service는 label selector를 사용하여 어떤 Pod들을 포함할지 결정합니다. Pod는 자신을 제공할 서비스에 라벨을 부여하여 해당 서비스와 연결될 수 있습니다.
6. **서비스 엔드포인트**: 각 서비스는 엔드포인트 리스트를 가지고 있습니다. 이 리스트는 해당 서비스와 연관된 Pod들의 IP 주소와 포트를 포함합니다.

### Service의 원리

- Pod의 경우에는 오토스케일링과 같은 동적으로 생성/삭제 및 재시작 되면서 그 IP가 바뀌기 때문에, Service에서 Pod의 목록을 필터할 때 IP주소를 이용하는 것은 어렵다. 그래서 사용하는 것이 label과 label selector 라는 개념이다.
  - spec.metadata 부분에 Pod 생성 시 사용할 label을 정의할 수 있다.
  - spec.selector.machLabels 부분에는 Service 생성 시 어떤 Pod들을 Service로 묶을 것인지 label selector를 정의한다.
- Service를 생성하면, label selector에서 특정 label을 가진 Pod들만 탐지한다. Service는 이렇게 필터된 Pod의 IP들을 엔드포인트로 묶어 관리하게 된다. 그래서 하나의 Service를 통해 여러 Pod에 로드밸런싱이 이루어질 수 있는 것이다.
- 그리고 Service를 생성하면 Service 이름으로 DNS가 생성되는데, 해당 DNS 이름으로 트래픽이 들어오면 여러 Pod의 엔드포인트로 로드밸런싱된다.

### Service 타입

#### (1) ClusterIP 
- 가장 기본이 되는 Service 타입이며, 클러스터 내부 통신만 가능하고 외부 트래픽은 받을 수 없다.
- 클러스터 내부에서 Service에 요청을 보낼 때, Service가 관리하는 Pod들에게 로드밸런싱하는 역할을 한다.

#### (2) NodePort
- 클러스터 내부 및 외부 통신이 가능한 Service 타입이다.
- NodePort는 외부 트래픽을 전달을 받을 수 있고, NodePort는 ClusetIP를 wrapping 하는 방식이기 때문에 종장의 흐름은 결국 ClusetIP 비슷한 방식으로 이루어진다.
- NodePort는 이름 그대로 노드의 포트를 사용한다. (30000-32767)
- 그리고 클러스터를 구성하는 각각의 Node에 동일한 포트를 열게 되는데, 이렇게 열린 포트를 통해서 Node마다 외부 트래픽을 받고 => 그게 결국 ClusetIP로 모인 후 다시 로드를 분산시키는 방식이다.

#### (3) LoadBalancer
- LoadBalancer는 기본적으로 외부에 존재하며, 보통 클라우드 프로바이더와 함께 사용되어 외부 트래픽을 받는 역할을 받는다.
- 받은 트래픽을 각각의 Service로 전달해서 L4 분배가 일어나게 된다.
- 역시 마찬가지로 흐름은 처음엔 LoadBalancer를 통하고, 이후엔 NodePort를 거쳐 ClusterIP로 이어지기 때문에 해당 기능을 모두 사용할 수 있다.
- 클라우드 프로바이더를 사용하는 경우 클라우드 로드밸런서를 사용하여 외부로 노출시킨다.

#### (4) ExternalName
- 위 3가지와 전혀 다른 Service 타입이라 할 수 있다. 다른 타입이 트래픽을 받기 위한 용도였다면 ExternalName 타입은 외부로 나가는 트래픽을 변환하기 위한 용도이다.
- ExternalName을 통해 a.b.com이라는 도메인 트래픽을 클러스터 내부에서는 a.b로 호출을 할 수 있게 해준다. 즉, 도메인 이름을 변환하여 연결해주는 역할을 한다.