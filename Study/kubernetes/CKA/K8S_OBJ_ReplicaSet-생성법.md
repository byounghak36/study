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
---
기본적인 작성방법은 Pod 작성할때와 동일합니다. kind 를 ReplicaSet으로 변경한 후 spec.template 하위에 Pod의 metadata, spec, selector를 기입합니다. ReplicaSet 은 selector를 통해 복제할 Pod를 추적하기에 꼭 작성하여야 합니다.

## 예시
---
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: myapp
    type: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-pod
        image: nginx
```

가장 기본적인 ReplicaSet yaml파일이다. 각 manifast를 하나하나 뜯어보자.

### 각 menifast 별 설명
---
#### apiVersion: apps/v1
Pod는 apiVersion을 v1으로 기입하였다. 또 ReplicaSet의 전신인 ReplicationController 또한 v1으로 기입하여 사용한다. 하지만 ReplicaSet은 apps/v1 에 포함되어 있기에 apiVersion을 꼭 apps/v1으로 기입하여야 한다.
#### kind: ReplicaSet
사용하고자 하는 object를 지정하는 곳이다. kind를 RecplicaSet으로 지정한다.
#### spec.replicas
ReplicaSet을 생성시 가장 중요한부분이 spec 부분이다. 해당 설정에서는 spec.replicas를 3으로 설정함으로서, 항상 3개의 Pod가 유지되도록 한다.
#### spec.selector.matchLables
이 부분이 ReplicationController 와 가장 큰 차이이다. 기존의 ReplicationController는 selector를 지정하지 않고 spec 에 기입된 Pod를 복제하였지만, ReplicaSet은 selector를 통해 선택된 Pod만 복제한다. 따라서 spec.template.metadata.labels 값을 잘 지정하는것도 중요하다.
#### spec.template
이 부분에 Pod를 생성할때 넣었던 metadata 및 spec을 기입한다. 실제로 생성될 Pod다. 만약 이부분을 생략하고 ReplicaSet을 생성한다면, 복제된 Pod는 없이 ReplicaSet만 생성된다.(이것도 필요에 따라 활용하기 좋다. 기존의 생성된 Pod를 복제하는 등...)

## 예시 적용


```shell
ubuntu@master01:~/yaml$ kubectl apply -f test-replicaset.yaml
ubuntu@master01:~/yaml$ kubectl get ReplicaSet -o wide
NAME       DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES   SELECTOR
frontend   3         3         3       26s   nginx-pod    nginx    app=nginx

# -l 옵션을 활용하여서 검색시 selector를 지정할 수 있다.
ubuntu@master01:~/yaml$ kubectl get pod -l app=nginx
NAME             READY   STATUS    RESTARTS   AGE
frontend-7bk4s   1/1     Running   0          13m
frontend-rhzhr   1/1     Running   0          13m
frontend-wlg8h   1/1     Running   0          13m

```

해당 파일을 apply 해보았다. 정상적으로 3개의 Pod가 생성된 모습이다.

만약 생성된 ReplicaSet의 Pod 개수를 조정하고 싶다면 어떻게 할까?

### ReplicaSet Pod 개수 조정

몇가지 방법이 있다. kubectl edit 을 활용하여 실행중인 ReplicaSet의 yaml을 수정하거나 kubectl 명령어를 통해서 조정할 수 있다. 

#### kubectl scale 으로 replicas 조정

```shell
ubuntu@master01:~/yaml$ kubectl scale replicaset frontend --replicas=5
replicaset.apps/frontend scaled
ubuntu@master01:~/yaml$ kubectl get ReplicaSet -o wide
NAME       DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES   SELECTOR
frontend   5         5         5       16m   nginx-pod    nginx    app=nginx
```

kubectl scale 명령어를 통해서 정상적으로 5개의 Pod 로 변경된 모습이다. --replicas 옵션을 통해서 replicas의 개수를 자유롭게 늘리거나 줄일 수 있다.

#### kubectl edit 으로 replicas 조정

입력창에 아래와같이 입려력한다.
```shell
ubuntu@master01:~/yaml$ kubectl edit rs frontend
```

> replicaset 대신 rs라고 입력하였다. 이와 같이 kubectl은 단축어 또한 지원한다.

입력하면 vim 편집기가 실행되면서 아래와 같이 yaml 파일이 열린다. 해당 yaml에서 수정하고자 하는 부분을 수정한다. 우리는 metadata.spec.replicas 를 수정한다.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"ReplicaSet","metadata":{"annotations":{},"labels":{"app":"myapp","type":"frontend"},"name":"frontend","namespace":"default"},"spec":{"replicas":3,"selector":{"matchLabels":{"app":"nginx"}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"containers":[{"image":"nginx","name":"nginx-pod"}]}}}}
  creationTimestamp: "2024-05-15T13:15:26Z"
  generation: 2
  labels:
    app: myapp
    type: frontend
  name: frontend
  namespace: default
  resourceVersion: "1070645"
  uid: 7a34a6ad-0869-4356-b3cc-13b0a8aba782
spec:
  replicas: 2 # 이 부분 수정
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx-pod
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 5
  fullyLabeledReplicas: 5
  observedGeneration: 2
  readyReplicas: 5
  replicas: 5
```

수정을 완료했다면 wq를 통해서 저장하고 빠져나온다.

```shell
replicaset.apps/frontend edited
ubuntu@master01:~/yaml$ kubectl get ReplicaSet -o wide
NAME       DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES   SELECTOR
frontend   2         2         2       20m   nginx-pod    nginx    app=nginx
```

replicaset 이 수정되었다는 출력과 함께 내가 수정한 replicas로 pod의 개수가 조정된 것을 확인할  수 있다.