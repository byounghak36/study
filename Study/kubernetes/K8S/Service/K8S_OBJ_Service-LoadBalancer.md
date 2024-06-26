---
title: K8S_Service_OBJ-LoadBalancer
tags:
  - kubernetes
  - K8S_OBJ_Service
date: 2024_04_21
Modify_Date: 
reference:
  - https://metallb.universe.tf/
---
![[Pasted image 20240516092516.png]]
# K8S_Service_OBJ-LoadBalancer

LoadBalancer 타입의 서비스는 AWS 와 같은 클라우드 플랫폼에서도 제공되지만, 필요시 온프레미스 환경에서 LoadBalancer 타입을 사용할 수 있습니다. 쿠버네티스가 이 기능을 직접 제공하는 것은 아니며, MetalLB나 오픈스택과 같은 특수한 환경을 구축해야만 합니다. 그중에서 MetalLB라는 이름의 오픈소스 프로젝트를 사용하면 쉽게 LoadBalancer 타입의 서비스를 사용할 수 있습니다. 이 글에서는 MetalLB가 설치되어있는 상황에서 해당 기능을 사용하는 방법을 설명합니다.

## MetalLB 란?
---
클라우드 플랫폼을 사용하지않고 on-premiss 상황에서 로드밸런서를 구현할 수 없는 상황의 경우 베어메탈서버에서 자체적으로 사용할 수 있는 Kubernetes Plugin 입니다.
MetalLB는 Kubernetes 클러스터에서 LoadBalancer 서비스를 제공하기 위해 설계된 네트워크 로드 밸런서 구현체입니다. MetalLB는 두 가지 주요 방식인 Layer 2 모드와 BGP(Border Gateway Protocol) 모드를 통해 작동합니다. 각 방식의 작동 원리와 장단점을 설명하겠습니다.

### Layer 2 방식
---
**Layer 2 방식**은 데이터 링크 계층(L2)에서 작동하며, ARP(주소 해석 프로토콜)를 이용해 네트워크 상의 IP 주소를 물리적 MAC 주소로 변환합니다.
#### 작동 원리:
1. MetalLB는 할당된 IP 풀에서 IP 주소를 선택합니다.
2. 선택된 IP 주소를 클러스터의 노드 중 하나에 할당합니다.
3. ARP 프로토콜을 사용하여 클러스터 내의 모든 노드에 IP 주소와 노드의 MAC 주소를 브로드캐스트합니다.
4. 네트워크 내의 다른 장치들은 이 정보를 이용해 해당 IP 주소로의 트래픽을 적절한 노드로 전달합니다.
#### 장점:
- 설정이 간단하고 별도의 라우터 구성 없이도 쉽게 사용할 수 있습니다.
- 소규모 네트워크에서 빠르게 설정할 수 있습니다.

### BGP 방식
---
**BGP 방식**은 네트워크 계층(L3)에서 작동하며, 경로 정보를 기반으로 패킷을 전달하는 경로 제어 프로토콜입니다.
#### 작동 원리:
1. MetalLB는 할당된 IP 풀에서 IP 주소를 선택합니다.
2. MetalLB는 BGP 피어링을 통해 라우터와 연결을 설정합니다.
3. 선택된 IP 주소에 대해 MetalLB는 BGP 라우터에 경로 정보를 광고합니다.
4. BGP 라우터는 이 정보를 사용하여 네트워크의 다른 라우터와 경로 정보를 교환합니다.
5. 클라이언트의 트래픽은 BGP 라우터를 통해 올바른 노드로 전달됩니다.
#### 장점:
- 매우 확장성이 뛰어나며, 대규모 네트워크에서도 효율적으로 작동합니다.
- BGP를 사용해 네트워크 간 경로 최적화가 가능합니다.
- L3 도메인 전체에서 작동하므로, 여러 L3 도메인에서도 사용이 가능합니다.

## LoadBalancer 작동 방식
---
![[Pasted image 20240516095017.png]]

위 사진은 로드밸런서를 통한 외부 접속 구성도이다.
WEB/WAS 가 배포되어 있고 각 Pod 는 Nodeport 서비스로 외부에서 접근할 수 있다. 하지만 NodePort는 노드의 IP를 직접 기입해야하는 문제가 있다.

**WEB**
- 192.168.118.10:31231
- 192.168.118.11:31231
- 192.168.118.12:31231
- 192.168.118.13:31231
**WAS**
- 192.168.118.10:31111
- 192.168.118.11:31111
- 192.168.118.12:31111
- 192.168.118.13:31111

매번 이렇게 입력해서 사용할 수 는 없지 않은가? 번거로움도 문제지만 노드의 IP를 직접 개방하는건 보안상의 문제가 있을 수 있다. 또 Node별 부하분산의 문제도 있다. 그래서 LB를 통해 외부로 서비스를 개방하는 것이다.

### LoadBalancer Yaml 작성 예시
---
#### Yaml 예시

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hostname-svc-lb
spec:
  type: LoadBalancer
  ports:
  - name: webserver
    port: 8080
    targetPort: 80
  selector:
    app: webserver
```

> 기존 NodePort 작성 방법과 크게 다르지 않다.
> 이전글 NodePort : https://exsso.tistory.com/21

#### 설명
- `kind: Service` Service 형식으로 `spec.type` 을 LoadBalancer 로 하여 생성하였다.
- `spec.ports.nodePort` 는 따로 기입하지 않았으니, nodePort는 랜덤으로 생성된다.
- `spec.selector` 를 `app: webserver` 로 지정하여, labels 가 `app:webserver` 인 파드에만 해당 Service 가 적용된다.

#### 적용
```shell
ubuntu@master01:~$ kubectl apply -f service-lbtest.yaml
ubuntu@master01:~$ kubectl get service
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
hostname-svc-lb                      LoadBalancer   10.233.11.178   10.101.0.50   8080:32202/TCP               5d22h
```

정상적으로 생성된것을 확인할 수 있다. 필자는 EXTERNAL-IP 의 범위를 10.101.0.50~60 으로 지정하여 MetalLB를 설치하였기에 10.101.0.50 으로 IP 가 잡힌 모양이다.
이제 외부에서도 10.101.0.50 IP 로 해당 Pod에 접근할 수 있다.