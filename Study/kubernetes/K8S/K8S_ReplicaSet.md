---
title: K8S_ReplicaSet
tags:
  - kubernetes
  - K8S_ReplicaSet
date: 2024_05_13
Modify_Date: 
reference: 
link:
---
ReplicaSet의 목적은 언제든지 실행되는 안정적인 복제본 Pod 세트를 유지하는 것입니다. 따라서 지정된 수의 동일한 Pod의 가용성을 보장하는 데 자주 사용됩니다.

## ReplicaSet의 작동 방식[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#how-a-replicaset-works)

ReplicaSet은 획득할 수 있는 Pod를 식별하는 방법을 지정하는 선택기, 유지해야 하는 Pod 수를 나타내는 복제본 수, 숫자를 충족하기 위해 생성해야 하는 새 Pod의 데이터를 지정하는 Pod 템플릿을 포함한 필드로 정의됩니다. 복제본 기준. 그런 다음 ReplicaSet는 원하는 수에 도달하기 위해 필요에 따라 Pod를 생성 및 삭제하여 목적을 달성합니다. ReplicaSet는 새 Pod를 생성해야 할 때 Pod 템플릿을 사용합니다.

ReplicaSet는 현재 객체가 소유한 리소스를 지정하는 Pod의 [Metadata.ownerReferences](https://kubernetes.io/docs/concepts/architecture/garbage-collection/#owners-dependents) 필드를 통해 Pod에 연결됩니다. ReplicaSet이 획득한 모든 Pod는 ownerReferences 필드 내에 소유한 ReplicaSet의 식별 정보를 가지고 있습니다. 이 링크를 통해 ReplicaSet는 유지 관리 중인 Pod의 상태를 알고 그에 따라 계획을 세웁니다.

ReplicaSet는 선택기를 사용하여 획득할 새 Pod를 식별합니다. OwnerReference가 없는 Pod가 있거나 OwnerReference가 아닌 경우[제어 장치](https://kubernetes.io/docs/concepts/architecture/controller/)ReplicaSet의 선택기와 일치하면 해당 ReplicaSet에 의해 즉시 획득됩니다.

## ReplicaSet을 사용해야 하는 경우[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#when-to-use-a-replicaset)

ReplicaSet은 특정 시간에 지정된 수의 Pod 복제본이 실행되도록 보장합니다. 그러나 배포는 ReplicaSet를 관리하고 다른 많은 유용한 기능과 함께 Pod에 대한 선언적 업데이트를 제공하는 더 높은 수준의 개념입니다. 따라서 사용자 지정 업데이트 오케스트레이션이 필요하지 않거나 업데이트가 전혀 필요하지 않은 경우가 아니면 ReplicaSet를 직접 사용하는 대신 배포를 사용하는 것이 좋습니다.

이는 실제로 ReplicaSet 객체를 조작할 필요가 전혀 없다는 의미입니다. 대신 배포를 사용하고 사양 섹션에서 애플리케이션을 정의하세요.

## 예[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#example)

[`controllers/frontend.yaml`](https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/controllers/frontend.yaml) ![](https://kubernetes.io/images/copycode.svg "Controller/frontend.yaml을 클립보드에 복사")

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # modify replicas according to your case
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
  template:
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: us-docker.pkg.dev/google-samples/containers/gke/gb-frontend:v5
```

이 매니페스트를 `frontend.yaml`Kubernetes 클러스터에 저장하고 제출하면 정의된 ReplicaSet과 이를 관리하는 Pod가 생성됩니다.

```shell
kubectl apply -f https://kubernetes.io/examples/controllers/frontend.yaml
```

그런 다음 현재 ReplicaSet를 배포할 수 있습니다.

```shell
kubectl get rs
```

그리고 생성한 프런트엔드를 확인하세요.

```
NAME       DESIRED   CURRENT   READY   AGE
frontend   3         3         3       6s
```

ReplicaSet의 상태를 확인할 수도 있습니다.

```shell
kubectl describe rs/frontend
```

그러면 다음과 유사한 출력이 표시됩니다.

```
Name:         frontend
Namespace:    default
Selector:     tier=frontend
Labels:       app=guestbook
              tier=frontend
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  tier=frontend
  Containers:
   php-redis:
    Image:        us-docker.pkg.dev/google-samples/containers/gke/gb-frontend:v5
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                   Message
  ----    ------            ----  ----                   -------
  Normal  SuccessfulCreate  13s   replicaset-controller  Created pod: frontend-gbgfx
  Normal  SuccessfulCreate  13s   replicaset-controller  Created pod: frontend-rwz57
  Normal  SuccessfulCreate  13s   replicaset-controller  Created pod: frontend-wkl7w
```

마지막으로 가져온 Pod를 확인할 수 있습니다.

```shell
kubectl get pods
```

다음과 유사한 Pod 정보가 표시됩니다.

```
NAME             READY   STATUS    RESTARTS   AGE
frontend-gbgfx   1/1     Running   0          10m
frontend-rwz57   1/1     Running   0          10m
frontend-wkl7w   1/1     Running   0          10m
```

또한 이러한 Pod의 소유자 참조가 프런트엔드 ReplicaSet으로 설정되어 있는지 확인할 수도 있습니다. 이렇게 하려면 실행 중인 Pod 중 하나의 yaml을 가져옵니다.

```shell
kubectl get pods frontend-gbgfx -o yaml
```

메타데이터의 ownerReferences 필드에 프런트엔드 ReplicaSet 정보가 설정된 경우 출력은 다음과 유사합니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2024-02-28T22:30:44Z"
  generateName: frontend-
  labels:
    tier: frontend
  name: frontend-gbgfx
  namespace: default
  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: frontend
    uid: e129deca-f864-481b-bb16-b27abfd92292
...
```

## 비템플릿 Pod 획득[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#non-template-pod-acquisitions)

문제 없이 베어 Pod를 생성할 수 있지만 베어 Pod에 ReplicaSet 중 하나의 선택기와 일치하는 라벨이 없는지 확인하는 것이 좋습니다. 그 이유는 ReplicaSet가 템플릿에 지정된 Pod 소유에만 국한되지 않고 이전 섹션에서 지정한 방식으로 다른 Pod를 획득할 수 있기 때문입니다.

이전 프런트엔드 ReplicaSet 예시와 다음 매니페스트에 지정된 Pod를 살펴보겠습니다.

[`pods/pod-rs.yaml`](https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/pods/pod-rs.yaml) ![](https://kubernetes.io/images/copycode.svg "Pods/pod-rs.yaml을 클립보드에 복사")

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  labels:
    tier: frontend
spec:
  containers:
  - name: hello1
    image: gcr.io/google-samples/hello-app:2.0

---

apiVersion: v1
kind: Pod
metadata:
  name: pod2
  labels:
    tier: frontend
spec:
  containers:
  - name: hello2
    image: gcr.io/google-samples/hello-app:1.0
```

해당 Pod에는 소유자 참조로 컨트롤러(또는 객체)가 없고 프런트엔드 ReplicaSet의 선택기와 일치하므로 즉시 획득됩니다.

프런트엔드 ReplicaSet이 배포되고 복제본 수 요구 사항을 충족하도록 초기 Pod 복제본을 설정한 후에 Pod를 생성한다고 가정해 보겠습니다.

```shell
kubectl apply -f https://kubernetes.io/examples/pods/pod-rs.yaml
```

새 Pod는 ReplicaSet에 의해 획득된 후 ReplicaSet가 원하는 수를 초과하므로 즉시 종료됩니다.

Pod를 가져오는 중:

```shell
kubectl get pods
```

출력에는 새 Pod가 이미 종료되었거나 종료되는 과정이 있음이 표시됩니다.

```
NAME             READY   STATUS        RESTARTS   AGE
frontend-b2zdv   1/1     Running       0          10m
frontend-vcmts   1/1     Running       0          10m
frontend-wtsmm   1/1     Running       0          10m
pod1             0/1     Terminating   0          1s
pod2             0/1     Terminating   0          1s
```

Pod를 먼저 생성하는 경우:

```shell
kubectl apply -f https://kubernetes.io/examples/pods/pod-rs.yaml
```

그런 다음 ReplicaSet을 생성합니다.

```shell
kubectl apply -f https://kubernetes.io/examples/controllers/frontend.yaml
```

ReplicaSet가 Pod를 획득하고 새 Pod 수와 원본이 원하는 수와 일치할 때까지 해당 사양에 따라 새 Pod만 생성한 것을 확인할 수 있습니다. Pod를 가져오는 방법:

```shell
kubectl get pods
```

출력에 다음이 표시됩니다.

```
NAME             READY   STATUS    RESTARTS   AGE
frontend-hmmj2   1/1     Running   0          9s
pod1             1/1     Running   0          36s
pod2             1/1     Running   0          36s
```

이러한 방식으로 ReplicaSet은 비동질적인 Pod 세트를 소유할 수 있습니다.

## ReplicaSet 매니페스트 작성[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#writing-a-replicaset-manifest)

다른 모든 Kubernetes API 객체와 마찬가지로 ReplicaSet에는 `apiVersion`, `kind`및 `metadata`필드가 필요합니다. ReplicaSet의 경우 `kind`항상 ReplicaSet입니다.

컨트롤 플레인이 ReplicaSet에 대한 새 Pod를 생성할 때 `.metadata.name`ReplicaSet의 는 해당 Pod 이름을 지정하는 기반의 일부입니다. ReplicaSet의 이름은 유효한 [DNS 하위 도메인](https://kubernetes.io/docs/concepts/overview/working-with-objects/names#dns-subdomain-names) 값이어야 하지만 이로 인해 Pod 호스트 이름에 대해 예상치 못한 결과가 발생할 수 있습니다. 최상의 호환성을 위해 이름은 [DNS 레이블](https://kubernetes.io/docs/concepts/overview/working-with-objects/names#dns-label-names) 에 대한 보다 제한적인 규칙을 따라야 합니다 .

ReplicaSet에는 [`.spec`섹션](https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status) 도 필요합니다 .

### Pod 템플릿[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#pod-template)

이는 레이블을 배치하는 데 필요한 [Pod 템플릿](https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates)`.spec.template` 입니다 . 이 예에서는 하나의 라벨이 있었습니다: . 다른 컨트롤러의 선택기와 겹치지 않도록 주의하세요. 그들이 이 Pod를 채택하려고 하지 않도록 하세요.[](https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates)`frontend.yaml``tier: frontend`

템플릿의 [다시 시작 정책](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy) 필드에 `.spec.template.spec.restartPolicy`허용되는 유일한 값은 `Always`기본값인 입니다.

### Pod 선택기[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#pod-selector)

필드 는 [라벨 선택기](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)`.spec.selector` 입니다 . [앞에서](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#how-a-replicaset-works) 설명한 것처럼 이는 획득할 잠재적인 Pod를 식별하는 데 사용되는 라벨입니다. 이 예에서 선택자는 다음과 같습니다.[](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#how-a-replicaset-works)`frontend.yaml`

```yaml
matchLabels:
  tier: frontend
```

ReplicaSet에서는 `.spec.template.metadata.labels`일치해야 합니다 `spec.selector`. 그렇지 않으면 API에 의해 거부됩니다.

**참고:** 동일 `.spec.selector`하지만 서로 다른 필드 `.spec.template.metadata.labels`를 지정하는 2개의 ReplicaSet의 경우 `.spec.template.spec`각 ReplicaSet는 다른 ReplicaSet에서 생성된 Pod를 무시합니다.

### 복제본[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#replicas)

를 설정하여 동시에 실행해야 하는 Pod 수를 지정할 수 있습니다 `.spec.replicas`. ReplicaSet는 이 숫자와 일치하도록 Pod를 생성/삭제합니다.

를 지정하지 않으면 `.spec.replicas`기본값은 1입니다.

## ReplicaSet 작업[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#working-with-replicasets)

### ReplicaSet 및 해당 Pod 삭제[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#deleting-a-replicaset-and-its-pods)

ReplicaSet 및 모든 해당 Pod를 삭제하려면 를 사용하세요 [`kubectl delete`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete). 가비지 [수집기는](https://kubernetes.io/docs/concepts/architecture/garbage-collection/) 기본적으로 모든 종속 Pod를 자동으로 삭제합니다.

REST API나 라이브러리를 사용하는 경우 옵션에서 또는 로 `client-go`설정해야 합니다 . 예를 들어:`propagationPolicy``Background``Foreground``-d`

```shell
kubectl proxy --port=8080
curl -X DELETE  'localhost:8080/apis/apps/v1/namespaces/default/replicasets/frontend' \
  -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Foreground"}' \
  -H "Content-Type: application/json"
```

### ReplicaSet만 삭제[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#deleting-just-a-replicaset)

[`kubectl delete`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete) 옵션을 사용하면 Pod에 영향을 주지 않고 ReplicaSet을 삭제할 수 있습니다 `--cascade=orphan`. REST API나 라이브러리를 사용하는 경우 로 `client-go`설정해야 합니다 . 예를 들어:`propagationPolicy``Orphan`

```shell
kubectl proxy --port=8080
curl -X DELETE  'localhost:8080/apis/apps/v1/namespaces/default/replicasets/frontend' \
  -d '{"kind":"DeleteOptions","apiVersion":"v1","propagationPolicy":"Orphan"}' \
  -H "Content-Type: application/json"
```

원본이 삭제되면 새 ReplicaSet을 생성하여 교체할 수 있습니다. 기존 Pod와 새 Pod가 `.spec.selector`동일한 한 새 Pod는 기존 Pod를 채택합니다. 그러나 기존 Pod를 새로운 다른 Pod 템플릿과 일치시키려는 노력은 하지 않습니다. 제어된 방식으로 Pod를 새 사양으로 업데이트하려면 [배포를](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment) 사용하세요 . ReplicaSet는 롤링 업데이트를 직접 지원하지 않기 때문입니다.

### ReplicaSet에서 Pod 격리[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#isolating-pods-from-a-replicaset)

라벨을 변경하여 ReplicaSet에서 Pod를 삭제할 수 있습니다. 이 기술은 디버깅, 데이터 복구 등을 위해 서비스에서 Pod를 제거하는 데 사용될 수 있습니다. 이 방식으로 제거된 Pod는 자동으로 교체됩니다(복제본 수도 변경되지 않는다고 가정).

### ReplicaSet 확장[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#scaling-a-replicaset)

ReplicaSet은 단순히 필드를 업데이트하여 쉽게 확장하거나 축소할 수 있습니다 `.spec.replicas`. ReplicaSet 컨트롤러는 일치하는 라벨 선택기가 있는 원하는 수의 Pod가 사용 가능하고 작동하는지 확인합니다.

축소할 때 ReplicaSet 컨트롤러는 다음 일반 알고리즘에 따라 Pod 축소 우선 순위를 지정하기 위해 사용 가능한 Pod를 정렬하여 삭제할 Pod를 선택합니다.

1. 보류 중인(및 예약할 수 없는) Pod가 먼저 축소됩니다.
2. `controller.kubernetes.io/pod-deletion-cost`주석이 설정된 경우 값이 더 낮은 Pod가 먼저 표시됩니다.
3. 복제본이 더 많은 노드의 Pod는 복제본이 더 적은 노드의 Pod보다 먼저 옵니다.
4. Pod의 생성 시간이 다른 경우 더 최근에 생성된 Pod가 이전 Pod보다 먼저 옵니다( `LogarithmicScaleDown` [기능 게이트가](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/) 활성화되면 생성 시간은 정수 로그 규모로 버킷화됩니다).

위의 사항이 모두 일치하면 무작위로 선택됩니다.

### Pod 삭제 비용[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#pod-deletion-cost)

기능 상태: `Kubernetes v1.22 [beta]`

주석을 사용하면 [`controller.kubernetes.io/pod-deletion-cost`](https://kubernetes.io/docs/reference/labels-annotations-taints/#pod-deletion-cost) 사용자는 ReplicaSet를 축소할 때 먼저 제거할 Pod에 대한 기본 설정을 지정할 수 있습니다.

주석은 Pod에 설정되어야 하며 범위는 [-2147483648, 2147483647]입니다. 동일한 ReplicaSet에 속한 다른 Pod와 비교하여 Pod를 삭제하는 비용을 나타냅니다. 삭제 비용이 낮은 Pod를 삭제 비용이 높은 Pod보다 먼저 삭제하는 것이 좋습니다.

이를 설정하지 않은 Pod에 대한 이 주석의 암시적 값은 0입니다. 음수 값이 허용됩니다. 잘못된 값은 API 서버에서 거부됩니다.

이 기능은 베타 버전이며 기본적으로 활성화되어 있습니다. kube-apiserver 및 kube-controller-manager 모두에서 [기능 게이트를](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/) 사용하여 이를 비활성화할 수 있습니다 .`PodDeletionCost`

**메모:**

- 이는 최선의 노력을 바탕으로 이루어지므로 Pod 삭제 순서에 대한 어떠한 보장도 제공하지 않습니다.
- 사용자는 메트릭 값을 기반으로 주석을 업데이트하는 등 주석을 자주 업데이트하지 않아야 합니다. 그렇게 하면 apiserver에서 상당한 수의 Pod 업데이트가 생성되기 때문입니다.

#### 사용 사례 예시[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#example-use-case)

애플리케이션의 다양한 Pod는 활용도 수준이 다를 수 있습니다. 규모를 축소할 경우 애플리케이션은 사용률이 낮은 Pod를 제거하는 것을 선호할 수 있습니다. Pod를 자주 업데이트하지 않으려면 `controller.kubernetes.io/pod-deletion-cost`축소를 실행하기 전에 애플리케이션을 한 번 업데이트해야 합니다 (주석을 Pod 활용도 수준에 비례하는 값으로 설정). 이는 애플리케이션 자체가 축소를 제어하는 ​​경우 작동합니다. 예를 들어 Spark 배포의 드라이버 Pod입니다.

### 수평형 Pod Autoscaler 대상인 ReplicaSet[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#replicaset-as-a-horizontal-pod-autoscaler-target)

[ReplicaSet는 HPA(Horizontal Pod Autoscalers)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) 의 대상이 될 수도 있습니다 . 즉, ReplicaSet은 HPA에 의해 자동 확장될 수 있습니다. 다음은 이전 예시에서 생성한 ReplicaSet를 대상으로 하는 HPA 예시입니다.

[`controllers/hpa-rs.yaml`](https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/controllers/hpa-rs.yaml) ![](https://kubernetes.io/images/copycode.svg "컨트롤러/hpa-rs.yaml을 클립보드에 복사")

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-scaler
spec:
  scaleTargetRef:
    kind: ReplicaSet
    name: frontend
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```

이 매니페스트를 `hpa-rs.yaml`Kubernetes 클러스터에 저장하고 제출하면 복제된 Pod의 CPU 사용량에 따라 대상 ReplicaSet를 자동 확장하는 정의된 HPA가 생성되어야 합니다.

```shell
kubectl apply -f https://k8s.io/examples/controllers/hpa-rs.yaml
```

또는 `kubectl autoscale`명령을 사용하여 동일한 작업을 수행할 수 있습니다(더 쉽습니다!).

```shell
kubectl autoscale rs frontend --max=10 --min=3 --cpu-percent=50
```

## ReplicaSet의 대안[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#alternatives-to-replicaset)

### 배포(권장)[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#deployment-recommended)

[`Deployment`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)ReplicaSet를 소유하고 선언적 서버 측 롤링 업데이트를 통해 ReplicaSet과 Pod를 업데이트할 수 있는 객체입니다. ReplicaSet는 독립적으로 사용할 수 있지만 현재는 주로 배포에서 Pod 생성, 삭제, 업데이트를 조정하는 메커니즘으로 사용됩니다. 배포를 사용하면 배포가 생성하는 ReplicaSet 관리에 대해 걱정할 필요가 없습니다. 배포는 ReplicaSet를 소유하고 관리합니다. 따라서 ReplicaSet을 원할 때는 배포를 사용하는 것이 좋습니다.

### 베어 Pod[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#bare-pods)

ReplicaSet은 사용자가 직접 Pod를 생성한 경우와 달리 노드 장애나 커널 업그레이드 등 방해가 되는 노드 유지 관리 등 어떤 이유로든 삭제되거나 종료되는 Pod를 대체합니다. 이러한 이유로 애플리케이션에 Pod가 하나만 필요한 경우에도 ReplicaSet을 사용하는 것이 좋습니다. 프로세스 감독자와 유사하게 생각하면 단일 노드의 개별 프로세스 대신 여러 노드에 걸쳐 여러 Pod를 감독한다는 점만 다릅니다. ReplicaSet은 Kubelet과 같은 노드의 일부 에이전트에 로컬 컨테이너 다시 시작을 위임합니다.

### 직업[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#job)

[`Job`](https://kubernetes.io/docs/concepts/workloads/controllers/job/)자체적으로 종료될 것으로 예상되는 Pod(즉, 일괄 작업)에는 ReplicaSet 대신 a를 사용하세요 .

### 데몬세트[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#daemonset)

[`DaemonSet`](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)머신 모니터링이나 머신 로깅과 같은 머신 수준 기능을 제공하는 Pod용 ReplicaSet 대신 a를 사용하세요 . 이러한 Pod에는 머신 수명과 연결된 수명이 있습니다. Pod는 다른 Pod가 시작되기 전에 머신에서 실행되어야 하며, 머신이 재부팅/종료될 준비가 되면 종료해도 안전합니다.

### 복제 컨트롤러[](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#replicationcontroller)

[ReplicaSets는 ReplicationControllers](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/) 의 후속 제품입니다 . 두 가지 모두 동일한 목적으로 사용되며 유사하게 작동합니다. 단, ReplicationController는 [레이블 사용자 가이드](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) 에 설명된 대로 세트 기반 선택기 요구 사항을 지원하지 않습니다 . 따라서 ReplicaSet는 ReplicationController보다 선호됩니다.