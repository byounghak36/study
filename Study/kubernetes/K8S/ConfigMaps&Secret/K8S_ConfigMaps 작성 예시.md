---
title: K8S_ConfigMaps 작성 예시
tags:
  - kubernetes
  - ConfigMaps
date: 2024_06_09
reference: 
link:
---

## ConfigMaps

```shell
controlplane ~ ➜  kubectl get configmap webapp-config-map -o yaml
```
```yaml
apiVersion: v1
data:
  APP_COLOR: darkblue
  APP_OTHER: disregard
kind: ConfigMap
metadata:
  creationTimestamp: "2024-06-09T09:27:03Z"
  name: webapp-config-map
  namespace: default
  resourceVersion: "996"
  uid: b1cb8b18-f13d-4524-ab1e-fda7cd6d147a
```

# 적용 방법
쿠버네티스에서 ConfigMap을 Pod에 적용하는 두 가지 방법은 `env`와 `envFrom`을 사용하는 것입니다. 두 방법 모두 ConfigMap의 데이터를 Pod의 컨테이너 환경 변수로 노출하는 데 사용되지만, 그 방식에는 중요한 차이점이 있습니다.

## 첫 번째 방법: `env` 사용
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2024-06-09T09:36:53Z"
  labels:
    name: webapp-color
  name: webapp-color
  namespace: default
  resourceVersion: "1189"
  uid: eb01277a-e971-41d8-8e93-27b4e3cc0c80
spec:
  containers:
  - env:
    - name: APP_COLOR
      valueFrom:
        configMapKeyRef:
          key: APP_COLOR
          name: webapp-config-map
```

#### 설명
- `env` 필드를 사용하면 Pod의 각 환경 변수를 개별적으로 설정할 수 있습니다.
- 위 예시에서는 ConfigMap `webapp-config-map`의 `APP_COLOR` 키 값을 Pod 컨테이너의 `APP_COLOR` 환경 변수로 설정합니다.
- 특정 키만 선택하여 환경 변수로 노출할 때 유용합니다.

## 두 번째 방법: `envFrom` 사용
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2024-06-09T09:36:53Z"
  labels:
    name: webapp-color
  name: webapp-color
  namespace: default
  resourceVersion: "1189"
  uid: eb01277a-e971-41d8-8e93-27b4e3cc0c80
spec:
  containers:
  - envFrom:
    - configMapKeyRef:
        name: webapp-config-map
```

#### 설명
- `envFrom` 필드를 사용하면 ConfigMap의 모든 키-값 쌍을 Pod 컨테이너의 환경 변수로 설정할 수 있습니다.
- 위 예시에서는 ConfigMap `webapp-config-map`의 모든 키-값 쌍을 환경 변수로 노출합니다.
- ConfigMap의 모든 값을 한 번에 환경 변수로 설정할 때 유용합니다.

---
### 요약

- `env`는 특정 ConfigMap 키만 선택적으로 환경 변수로 설정할 수 있습니다. 따라서 더 세밀한 제어가 가능합니다.
- `envFrom`은 ConfigMap의 모든 키를 한 번에 환경 변수로 설정할 수 있어, 설정이 간단해집니다.

두 방법 중 어떤 것을 사용할지는 설정의 필요에 따라 달라집니다. 예를 들어, ConfigMap의 일부 키만 필요하다면 `env`를 사용하고, ConfigMap의 모든 키를 환경 변수로 사용하고자 한다면 `envFrom`을 사용하는 것이 적절합니다.