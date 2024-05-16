---
title: K8S_선언형VS명령형_시험팁
tags:
  - kubernetes
  - CKA
date: 2024_05_16
reference: 
link:
  - https://seongjin.me/kubernetes-imparative-vs-declarative/
---
# 인증 팁 - Kubectl을 사용한 명령형 명령어

대부분 선언적 방법, 즉 정의 파일을 사용하는 작업을 하겠지만, 명령형 명령어는 한 번의 작업을 빠르게 완료하거나 정의 템플릿을 쉽게 생성하는 데 도움이 될 수 있습니다. 이는 시험 중에 상당한 시간을 절약할 수 있게 해줍니다. 시작하기 전에 아래 명령어를 사용할 때 유용할 수 있는 두 가지 옵션을 숙지하십시오:

`--dry-run`: 기본적으로 명령어를 실행하면 리소스가 생성됩니다. 단순히 명령어를 테스트하고 싶다면 `--dry-run=client` 옵션을 사용하십시오. 이는 리소스를 생성하지 않고, 리소스를 생성할 수 있는지와 명령어가 올바른지를 알려줍니다.
`-o yaml`: 이는 화면에 YAML 형식으로 리소스 정의를 출력합니다.

위 두 가지를 조합하여 리소스 정의 파일을 빠르게 생성한 후 수정하여 필요한 리소스를 생성할 수 있습니다. 이는 파일을 처음부터 만드는 대신 유용하게 사용할 수 있습니다.

### 옵션 사용 방법

#### 1. `--dry-run = none`
실제로 명령을 실행하고 변경을 API 서버에 적용합니다. 이것은 `dry-run`을 사용하지 않는 행동과 동일합니다.

#### 2. `--dry-run = client`

`Kubernetes API` 서버에 어떠한 요청도 전송되지 않습니다.
실제 서버의 유효성 검사나 기타 로직은 수행되지 않기 때문에, 명령이 실제로 실행될 때와 다른 결과가 나올 수 있습니다.

#### 3. `--dry-run = server`

이 옵션은 명령을 실제로 실행하는 것처럼 `Kubernetes API 서버`에 요청을 전송합니다.
서버는 요청을 처리하고 예상되는 결과를 반환하지만, 실제로 변경사항은 저장되거나 적용되지 않습니다.
이 방식을 사용하면, 서버의 유효성 검사, 기본 값 설정, 기타 요청 처리 로직을 포함한 실제 명령 처리의 전체 라이프사이클을 시뮬레이션할 수 있습니다.
### client vs server
🤓client와 server의 경우 이해가 되지 않을 수 있지만 간단하게 말해서 값이 존재하지 않는 네임스페이스에서 파드를 생성한다고 가정할 때 client 옵션은 문제가 없는 것 처럼 나오지만 server로 실행하면 에러를 감지하게 됩니다.
🤗상황에 따라 필요한신 옵션을 선택하여 사용하시면 좋을 것 같습니다.


### 사용 예시
#### POD
**NGINX Pod 생성**
`kubectl run nginx --image=nginx`

**POD 매니페스트 YAML 파일 생성(-o yaml). 생성하지 않음(--dry-run)**
`kubectl run nginx --image=nginx --dry-run=client -o yaml`

#### Deployment
**디플로이먼트 생성**
`kubectl create deployment --image=nginx nginx`

**디플로이먼트 YAML 파일 생성(-o yaml). 생성하지 않음(--dry-run)**
`kubectl create deployment --image=nginx nginx --dry-run=client -o yaml`

**4개의 레플리카로 디플로이먼트 생성**
`kubectl create deployment nginx --image=nginx --replicas=4`

디플로이먼트를 확장하려면 `kubectl scale` 명령어를 사용할 수 있습니다.
`kubectl scale deployment nginx --replicas=4`

**또 다른 방법은 YAML 정의를 파일에 저장하고 수정하는 것입니다**
`kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml`

그런 다음 YAML 파일을 업데이트하여 레플리카 또는 다른 필드를 수정한 후 디플로이먼트를 생성할 수 있습니다.

#### Service
**Pod redis를 포트 6379로 노출하는 ClusterIP 타입의 redis-service 생성**
`kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml`
(이는 자동으로 pod의 라벨을 셀렉터로 사용합니다)

`kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml` 
(이는 pod의 라벨을 셀렉터로 사용하지 않고, 대신 **app=redis**로 셀렉터를 가정합니다. [선택 옵션으로 셀렉터를 전달할 수 없습니다.](https://github.com/kubernetes/kubernetes/issues/46191) 따라서 pod에 다른 라벨이 설정되어 있는 경우 잘 작동하지 않습니다. 파일을 생성한 후 셀렉터를 수정한 다음 서비스를 생성하십시오.)

**Pod nginx의 포트 80을 노드의 포트 30080으로 노출하는 NodePort 타입의 nginx 서비스 생성**
`kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml`
(이는 자동으로 pod의 라벨을 셀렉터로 사용하지만, [노드 포트를 지정할 수 없습니다](https://github.com/kubernetes/kubernetes/issues/25478). 정의 파일을 생성한 후 노드 포트를 수동으로 추가한 다음 pod로 서비스를 생성해야 합니다.)

`kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml`
(이는 pod의 라벨을 셀렉터로 사용하지 않습니다)

위 명령어들은 각각의 도전 과제가 있습니다. 하나는 셀렉터를 허용할 수 없고, 다른 하나는 노드 포트를 허용할 수 없습니다. `kubectl expose` 명령어를 사용하는 것을 권장합니다. 노드 포트를 지정해야 하는 경우, 동일한 명령어를 사용하여 정의 파일을 생성한 후 노드 포트를 수동으로 입력한 다음 서비스를 생성하십시오.

#### **참조:**
[https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
[https://kubernetes.io/docs/reference/kubectl/conventions/](https://kubernetes.io/docs/reference/kubectl/conventions/)