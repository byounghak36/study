---
title: 무제 파일
tags:
  - kubernetes
  - K8S_OBJ_scheduler
date: 2024_05_17
reference: 
link:
  - "[[K8S_kubectl_explain 옵션]]"
---
## **Node Affinity**

**노드 어피니티(Node Affinity)** 는 노드 셀렉터와 비슷하게 노드의 레이블을 기반으로 파드를 스케쥴링합니다. 노드 어피니티와 노드셀렉터를 함께 설정할 수도 있으며, 이 때는 노드 어피니티와 노드셀렉터의 조건을 모두 만족하는 노드에 파드를 스케쥴링합니다.

참고로 Affinity는 한국어로 다음과 같은 의미를 가집니다.

1.친밀감 (=rapport)  
2.(밀접한) 관련성, 친연성

노드 어피니티에는 두 가지 필드가 있습니다.

- **requiredDuringSchedulingIgnoredDuringExecution** : '스케쥴링하는 동안 **꼭 필요한**' 조건
- **preferredDuringSchedulingIgnoredDuringExecution** : '스케쥴링하는 동안 **만족하면 좋은**' 조건입니다. 꼭 이 조건을 만족해야하는 것은 아니라는 의미입니다.

필드명이 길지만 **required(필수)**와 **preferred(선호)**에 의미를 두면 이해하기 쉬울 것 같습니다.

**두 필드는 '실행 중에 조건이 바뀌어도 무시'합니다.**
파드가 이미 스케줄링되어 특정 노드에서 실행 중이라면 중간에 해당 노드의 조건이 변경되더라도 이미 실행 중인 파드는 그대로 실행된다는 뜻입니다. 

### requiredDuringSchedulingIgnoredDuringExecution

**requiredDuringSchedulingIgnoredDuringExecution**를 구성하는 매니페스트 파일의 예시는 다음과 같습니다.

```
...중략...
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: disktype
          operator: In
          values:
          - ssd
```

**requiredDuringSchedulingIgnoredDuringExecution**의 하위 필드로는 노드 어피니티 유형과 연관된 노드 셀렉터 설정을 연결하는 nodeSelectorTerms 와 matchExpressions 필드가 있습니다. matchExpressions 의 하위 필드로는 key, operator, values 가 있습니다.

key는 노드의 레이블 키 중 하나를 설정하고 operator 는 key 가 만족할 조건이며 설정할 수 있는 값은 다음과 같습니다.

| key 필드 값     | 설명                                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------------------ |
| In           | values[] 필드에 설정한 값 중 레이블에 있는 값과 일치하는 것이 하나라도 있는지 확인합니다.                                                |
| NotIn        | In과 반대로 values[]에 있는 값 모두와 맞지 않는 지 확인합니다.                                                              |
| Exists       | key 필드에 설정한 값이 레이블에 있는지만 확인합니다. (values[] 필드가 필요 없습니다.)                                                |
| DoseNotExist | Exists와 반대로 노드의 레이블에 key 필드 값이 없는지만 확인합니다.                                                             |
| Gt           | Greater than의 약자로 values[] 필드에 설정된 값이 설정된 값 보다 더 큰 숫자형 데이터 인지 확인합니다. 이 때 values[] 필드에는 값이 하나만 있어야 합니다. |
| Lt           | Lower than의 약자로 values[] 필드에 설정된 값이 설정된 값 보다 더 작은 숫자형 데이터 인지 확인합니다. 이 때 values[] 필드에는 값이 하나만 있어야 합니다.  |

### preferredDuringSchedulingIgnoredDuringExecution

**preferredDuringSchedulingIgnoredDuringExecution**를 구성하는 매니페스트 파일의 예시는 다음과 같습니다.

```
...생략
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 10
  preference:
  - matchExpressions:
    - key: disktype
      operator: In
      values:
      - hdd
```

**preferredDuringSchedulingIgnoredDuringExecution** 필드는 하위필드로 weight 필드가 있다는 점과 nodeSelectorTerms[] 필드 대신 preference 필드를 사용한다는 점만 빼면 **requiredDuringSchedulingIgnoredDuringExecution** 필드와 설정이 비슷합니다.

preference 필드는 해당 조건에 맞는 걸 선호한다는 의미 입니다. preference 필드의 조건에 따라 맞는 노드를 우선해서 선택하지만 없다면 없는 대로 조건에 맞지 않는 노드에 파드를 스케줄링하여 실행합니다.

weight 필드는 1부터 100까지의 값을 설정할 수 있습니다. 여러 개  matchExpressions 필드 안 설정 각각이 노드의 설정과 맞을 때 마다 weight 필드 값을 더합니다. 그리고 모든 노드 중에서 weight 필드 값의 합계가 가장 큰 노드를 선택합니다.

---

**Node Affinity 예시(**requiredDuringSchedulingIgnoredDuringExecution)

노드 어피니티를 실행하기 위해서는 쿠버네티스 서버의 버전은 다음과 같거나 더 높아야 합니다. 버전: v1.10.  
그리고 노드의 구분을 위해 적어도 2개의 워커 노드가 필요합니다.

#### 노드에 Label 추가

1. 우선 클러스터의 노드 나열 합니다.

```
kubectl get nodes --show-labels
```

결과는 다음과 같습니다.

```
NAME         STATUS   ROLES                  AGE   VERSION   LABELS
k8s-master   Ready    control-plane,master   21d   v1.22.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-master,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
k8s-node1    Ready    <none>                 21d   v1.22.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-node1,kubernetes.io/os=linux
k8s-node2    Ready    <none>                 21d   v1.22.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-node2,kubernetes.io/os=linux
```

2. 노드를 하나 선택하여 label을 추가합니다. 

저는 k8s-node1에 추가하도록 하겠습니다. 추가할 label은 disktype=ssd 라는 label입니다.

```
kubectl label nodes k8s-node1 disktype=ssd
```

3. 추가한 노드에 distype=ssd 라는 label을 가지고 있는지 확인합니다.

```
kubectl get nodes --show-labels
```

```
[root@k8s-master ~]# kubectl get nodes --show-labels
NAME         STATUS   ROLES                  AGE   VERSION   LABELS
k8s-master   Ready    control-plane,master   21d   v1.22.0   <생략>
k8s-node1    Ready    <none>                 21d   v1.22.0   <중략> ... disktype=ssd
k8s-node2    Ready    <none>                 21d   v1.22.0   <생략>
```

k8s-node1에 distktype=ssd 레이블이 생성된 것을 확인할 수 있습니다.

#### 노드 어피니티를 사용하여 파드 스케줄링

다음은 nginx 이미지를  distktype=ssd  라는 label을 가진 노드에 스케줄링하도록 하는 매니페스트 파일입니다.  

```
# pod-nginx-required-affinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  # affinity
  affinity:
    nodeAffinity:
      # required
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        # disktype이 ssd인 node에 파드 생성
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd            
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

1. 위 매니페스트 파일을 적용하여 파드를 생성합니다.

```
$ kubectl apply -f pod-nginx-required-affinity.yaml
pod/nginx created
```

확실하게 보기 위해 파드의 이름을 nginx2로 변경한 후 파드를 하나 더 생성하겠습니다.

```
$ kubectl apply -f pod-nginx-required-affinity.yaml
pod/nginx2 created
```

2. 파드가 선택한 노드에서 실행 중인지 확인합니다.

```
$ kubectl get pods --output=wide
NAME     READY   STATUS    RESTARTS   AGE   IP               NODE        NOMINATED NODE   READINESS GATES
nginx    1/1     Running   0          63s   20.111.156.123   k8s-node1   <none>           <none>
nginx2   1/1     Running   0          3s    20.111.156.124   k8s-node1   <none>           <none>
```

실행결과(캡쳐)

![](https://blog.kakaocdn.net/dn/onk5A/btrrhFXqCvQ/vbtejY6yA8GPLYfVsQIMZK/img.png)

k8s-node1에 disktype=ssd라는 레이블을 추가하였기 때문에 nginx 파드가 k8s-node1에만 할당되는 것을 확인할 수 있습니다.

다음과 같이 disktype=hdd 라는 레이블이 있는 노드에 추가하도록 변경하면 어떻게 될까요?

```
# pod-nginx-required-affinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx2
spec:
  # affinity
  affinity:
    nodeAffinity:
      # required
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        # disktype이 ssd인 node에 파드 생성
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - hdd            
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

위와 같이 매니페스트 파일을 변경하여 다시 실행합니다.

```
$ kubectl apply -f pod-nginx-required-affinity.yaml
pod/nginx created
```

그리고 확인을 해보면

```
$ kubectl get pods --output=wide
NAME     READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
nginx    0/1     Pending   0          15s   <none>   <none>   <none>           <none>
```

pod가 Pending 상태에서 시작되지 못하는 것을 확인할 수 있습니다.

다음 명령어로 파드의 상태를 출력해봅니다.

```
$ kubectl describe pod nginx
..생략..
Events:
  Type     Reason            Age                From               Message
  ----     ------            ----               ----               -------
  Warning  FailedScheduling  28s (x2 over 90s)  default-scheduler  0/3 nodes are available: 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate, 2 node(s) didn't match Pod's node affinity/selector.
```

FailedScheduling이라는 Reason으로 파드가 스케줄링 되지 못했다는 것을 알 수 있으며 Message를 살펴보면 다음과 같습니다.

> 0/3 nodes are available: 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate, 2 node(s) didn't match Pod's node affinity/selector

해석하자면 다음과 같습니다.  노드가 3개가 있는데 1개는 taint로 허용하지 않는 노드고(Master node), 2개의 파드는 affinity selector와 일치하지 않는다. **requiredDuringSchedulingIgnoredDuringExecution** 필드로 설정하였기 때문에 affinity 필드에서 설정한 selector와 일치하지 않는 경우 파드를 생성하지 않습니다.

마지막으로 위의 매니페스트 파일에서 **requiredDuringSchedulingIgnoredDuringExecution를** ****preferredDuringSchedulingIgnoredDuringExecution****로 변경하여 실행해 보겠습니다.

****Node Affinity 예시(**preferredDuringSchedulingIgnoredDuringExecution****)  
******disktype=hdd 인 레이블을 가진 노드를 선호하도록 다음과 같이 파드를 구성합니다.

```
# pod-nginx-required-affinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx2
spec:
  # affinity
  affinity:
    nodeAffinity:
      # preferred
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 10
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - hdd
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

1. 위 매니페스트 파일을 적용하여 파드를 생성합니다.

```
$ kubectl apply -f pod-nginx-required-affinity.yaml
pod/nginx created
```

2. 파드가 실행 중인지 확인합니다.

```
$ kubectl get pods --output=wide
NAME     READY   STATUS    RESTARTS   AGE   IP               NODE        NOMINATED NODE   READINESS GATES
nginx    1/1     Running   0          3s    20.109.131.13    k8s-node2   <none>           <none>
nginx2   1/1     Running   0          51s   20.111.156.125   k8s-node1   <none>           <none>
```

위의 예시 처럼 두 개의 파드를 생성하였으며  두 개의 파드 모두 disktype=hdd 인 레이블이 없기 때문에 파드가 k8s-node1, k8s-node2에 각각 하나씩 생성된 것을 확인할 수 있습니다.

출처: [https://kimjingo.tistory.com/144](https://kimjingo.tistory.com/144) [김징어의 Devlog:티스토리]