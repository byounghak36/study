---
title: K8S_OBJ_ReplicaSet-생성법
tags:
  - kubernetes
  - K8S_ReplicaSet
date: 2024_05_15
reference:
  - https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
link:
  - "[[K8S_OBJ_ReplicaSet]]"
  - "[[K8S_ReplicaSet-YAML_작성법]]"
---
# Kubernetes ReplicaSet 생성법

기본적인 작성방법은 Pod 작성할때와 동일합니다. kind 를 ReplicaSet으로 변경한 후 spec.template 하위에 Pod의 metadata, spec, selector를 기입합니다. ReplicaSet 은 selector를 통해 복제할 Pod를 추적하기에 꼭 작성하여야 합니다.

## 예시

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx-pod
        image: nginx
```

가장 기본적인 ReplicaSet yaml파일이다. 각 manifast를 하나하나 뜯어보자.

### 각 menifast 별 설명

#### apiVersion: apps/v1
Pod는 apiVersion을 v1으로 기입하였다. 또 ReplicaSet의 전신인 ReplicationController 또한 v1으로 기입하여 사용한다. 하지만 ReplicaSet은 apps/v1 에 포함되어 있기에 apiVersion을 꼭 apps/v1으로 기입하여야 한다.
#### kind: ReplicaSet
사용하고자 하는 object를 지정하는 곳이다. kind를 RecplicaSet으로 지정한다.
#### metadata.labels.app: frontend


