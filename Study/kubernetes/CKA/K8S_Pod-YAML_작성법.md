---
title: K8S_YAML_작성법
tags:
  - kubernetes
  - yaml
date: 2024_05_12
Modify_Date: 
reference: 
link:
---
## Yaml 이란?
쿠버네티스 에서는 yaml형식을 사용하여 pod 및 모든 오브젝트를 생성 및 관리합니다. yaml은 key-value로 이루어진 언어 형식이며, etcd에 데이터를 저장하는 쿠버네티스에서 활용하기 좋은 형식입니다.

## Yaml 작성 예시
```yaml  pod-defintion.yaml
apiVersion:
kind:
metadata:

spec:
```

기본적으로 4가지 필수 필드를 입력하고 필요한 부분들을 추가하는것이 좋습니다.

각 설명을 하자면
- apiVersion : 생성할 때 사용할 쿠버네티스 API 버전을 입력합니다. 각 오브젝트별로 api 버전이 다릅니다.
  ![[Pasted image 20240513161457.png]]
- kind : 오브젝트 유형을 나타냅니다. Pod, Replica, Deployment, Serivce 등을 입력합니다.
- metadata : 이름과 라벨등 하위 집합체를 입력합니다.
  ![[Pasted image 20240513161644.png]]
- spec : 생성하려는 오브젝트의 정보를 입력합니다. pod 를 생성한다면 아래와 비슷한 구조로 입력하게 됩니다.
  ![[Pasted image 20240513161736.png]]
  