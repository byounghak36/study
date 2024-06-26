---
title: K8S_Static_pod
tags:
  - kubernetes
date: 2024_05_19
reference: 
link:
---
- [[#시작하기 전에[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-%EC%A0%84%EC%97%90)|시작하기 전에[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-%EC%A0%84%EC%97%90)]]
- [[#스태틱 파드 생성하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#static-pod-creation)|스태틱 파드 생성하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#static-pod-creation)]]
	- [[#스태틱 파드 생성하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#static-pod-creation)#파일시스템이 호스팅 하는 스태틱 파드 매니페스트|파일시스템이 호스팅 하는 스태틱 파드 매니페스트]]
	- [[#스태틱 파드 생성하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#static-pod-creation)#웹이 호스팅 하는 스태틱 파드 매니페스트|웹이 호스팅 하는 스태틱 파드 매니페스트]]
- [[#스태틱 파드 행동 관찰하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#behavior-of-static-pods)|스태틱 파드 행동 관찰하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#behavior-of-static-pods)]]
- [[#스태틱 파드의 동적 추가 및 제거[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#%EC%8A%A4%ED%83%9C%ED%8B%B1-%ED%8C%8C%EB%93%9C%EC%9D%98-%EB%8F%99%EC%A0%81-%EC%B6%94%EA%B0%80-%EB%B0%8F-%EC%A0%9C%EA%B1%B0)|스태틱 파드의 동적 추가 및 제거[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#%EC%8A%A4%ED%83%9C%ED%8B%B1-%ED%8C%8C%EB%93%9C%EC%9D%98-%EB%8F%99%EC%A0%81-%EC%B6%94%EA%B0%80-%EB%B0%8F-%EC%A0%9C%EA%B1%B0)]]

---
# 스태틱(static) 파드 생성하기

_스태틱 파드_ 는 [API 서버](https://kubernetes.io/ko/docs/concepts/overview/components/#kube-apiserver) 없이 특정 노드에 있는 kubelet 데몬에 의해 직접 관리된다. 컨트롤 플레인에 의해 관리되는 파드(예를 들어 [디플로이먼트(Deployment)](https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/))와는 달리, kubelet 이 각각의 스태틱 파드를 감시한다. (만약 실패할 경우 다시 구동한다.)

스태틱 파드는 항상 특정 노드에 있는 하나의 [Kubelet](https://kubernetes.io/docs/reference/generated/kubelet)에 매여 있다.

Kubelet 은 각각의 스태틱 파드에 대하여 쿠버네티스 API 서버에서 [미러 파드(mirror pod)](https://kubernetes.io/ko/docs/reference/glossary/?all=true#term-mirror-pod)를 생성하려고 자동으로 시도한다. 즉, 노드에서 구동되는 파드는 API 서버에 의해서 볼 수 있지만, API 서버에서 제어될 수는 없다. 파드 이름에는 노드 호스트 이름 앞에 하이픈을 붙여 접미사로 추가된다.


> [!NOTE] 참고
> 만약 클러스터로 구성된 쿠버네티스를 구동하고 있고, 스태틱 파드를 사용하여 모든 노드에서 파드를 구동하고 있다면, 스태틱 파드를 사용하는 대신 [데몬셋(DaemonSet)](https://kubernetes.io/ko/docs/concepts/workloads/controllers/daemonset) 을 사용하는 것이 바람직하다.

> [!NOTE] 참고
스태틱 파드의 `spec`은 다른 API 오브젝트(예를 들면, [서비스어카운트](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/), [컨피그맵](https://kubernetes.io/ko/docs/concepts/configuration/configmap/), [시크릿](https://kubernetes.io/ko/docs/concepts/configuration/secret/), 등)가 참조할 수 없다.

> [!NOTE]
스태틱 파드는 [임시 컨테이너](https://kubernetes.io/ko/docs/concepts/workloads/pods/ephemeral-containers/)를 지원하지 않는다.

## 시작하기 전에[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-%EC%A0%84%EC%97%90)

쿠버네티스 클러스터가 필요하고, kubectl 커맨드-라인 툴이 클러스터와 통신할 수 있도록 설정되어 있어야 한다. 이 튜토리얼은 컨트롤 플레인 호스트가 아닌 노드가 적어도 2개 포함된 클러스터에서 실행하는 것을 추천한다. 만약, 아직 클러스터를 가지고 있지 않다면, [minikube](https://kubernetes.io/ko/docs/tasks/tools/#minikube)를 사용해서 생성하거나 다음 쿠버네티스 플레이그라운드 중 하나를 사용할 수 있다.

- [Killercoda](https://killercoda.com/playgrounds/scenario/kubernetes)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)

버전 확인을 위해서, 다음 커맨드를 실행 `kubectl version`.

이 페이지는 파드를 실행하기 위해 [CRI-O](https://cri-o.io/#what-is-cri-o)를 사용하며, 노드에서 Fedora 운영 체제를 구동하고 있다고 가정한다. 다른 배포판이나 쿠버네티스 설치 지침과는 다소 상이할 수 있다.

## 스태틱 파드 생성하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#static-pod-creation)

[[### 파일시스템이 호스팅 하는 스태틱 파드 매니페스트]]이나 [[### 웹이 호스팅 하는 스태틱 파드 매니페스트]] [[K8S_Static_pod|]]을 사용하여 스태틱 파드를 구성할 수 있다.

### 파일시스템이 호스팅 하는 스태틱 파드 매니페스트

매니페스트는 특정 디렉터리에 있는 JSON 이나 YAML 형식의 표준 파드 정의이다. [kubelet 구성 파일](https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/)의 `staticPodPath: <the directory>` 필드를 사용하자. 명시한 디렉터리를 정기적으로 스캔하여, 디렉터리 안의 YAML/JSON 파일이 생성되거나 삭제되었을 때 스태틱 파드를 생성하거나 삭제한다. Kubelet 이 특정 디렉터리를 스캔할 때 점(.)으로 시작하는 단어를 무시한다는 점을 유의하자.

예를 들어, 다음은 스태틱 파드로 간단한 웹 서버를 구동하는 방법을 보여준다.

1. 스태틱 파드를 실행할 노드를 선택한다. 이 예제에서는 `my-model` 이다.
    
    ```shell
    ssh my-node1
    ```
    
2. `/etc/kubernetes/manifests` 와 같은 디렉터리를 선택하고 웹 서버 파드의 정의를 해당 위치에, 예를 들어 `/etc/kubernetes/manifests/static-web.yaml` 에 배치한다.
    
```shell
# kubelet 이 동작하고 있는 노드에서 이 명령을 수행한다.
    mkdir -p /etc/kubernetes/manifests/
    cat <<EOF >/etc/kubernetes/manifests/static-web.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: static-web
      labels:
        role: myrole
    spec:
      containers:
        - name: web
          image: nginx
          ports:
            - name: web
              containerPort: 80
              protocol: TCP
    EOF
```

    
1. 노드에서 kubelet 실행 시에 `--pod-manifest-path=/etc/kubernetes/manifests/` 와 같이 인자를 제공하여 해당 디렉터리를 사용하도록 구성한다. Fedora 의 경우 이 줄을 포함하기 위하여 `/etc/kubernetes/kubelet` 파일을 다음과 같이 수정한다.
    
    ```
    KUBELET_ARGS="--cluster-dns=10.254.0.10 --cluster-domain=kube.local --pod-manifest-path=/etc/kubernetes/manifests/"
    ```
    
    혹은 [kubelet 구성 파일](https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/)에 `staticPodPath: <the directory>` 필드를 추가한다.
    
4. kubelet을 재시작한다. Fedora의 경우 아래와 같이 수행한다.
    
    ```shell
    # kubelet 이 동작하고 있는 노드에서 이 명령을 수행한다.
    systemctl restart kubelet
    ```
    

### 웹이 호스팅 하는 스태틱 파드 매니페스트

Kubelet은 `--manifest-url=<URL>` 의 인수로 지정된 파일을 주기적으로 다운로드하여 해당 파일을 파드의 정의가 포함된 JSON/YAML 파일로 해석한다. [[### 파일시스템이 호스팅 하는 스태틱 파드 매니페스트]] 의 작동 방식과 유사하게 kubelet은 스케줄에 맞춰 매니페스트 파일을 다시 가져온다. 스태틱 파드의 목록에 변경된 부분이 있을 경우, kubelet 은 이를 적용한다.

이 방법을 사용하기 위하여 다음을 수행한다.

1. kubelet 에게 파일의 URL을 전달하기 위하여 YAML 파일을 생성하고 이를 웹 서버에 저장한다.
    
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: static-web
      labels:
        role: myrole
    spec:
      containers:
        - name: web
          image: nginx
          ports:
            - name: web
              containerPort: 80
              protocol: TCP
    ```
    
2. 선택한 노드에서 `--manifest-url=<manifest-url>` 을 실행하여 웹 메니페스트를 사용하도록 kubelet을 구성한다. Fedora 의 경우 이 줄을 포함하기 위하여 `/etc/kubernetes/kubelet` 파일을 수정한다.
    
    ```
    KUBELET_ARGS="--cluster-dns=10.254.0.10 --cluster-domain=kube.local --manifest-url=<manifest-url>"
    ```
    
3. Kubelet을 재시작한다. Fedora의 경우 아래와 같이 수행한다.
    
    ```shell
    # kubelet 이 동작하고 있는 노드에서 이 명령을 수행한다.
    systemctl restart kubelet
    ```
    

## 스태틱 파드 행동 관찰하기[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#behavior-of-static-pods)

Kubelet 을 시작하면, 정의된 모든 스태틱 파드가 자동으로 시작된다. 스태틱 파드를 정의하고, kubelet을 재시작했으므로, 새로운 스태틱 파드가 이미 실행 중이어야 한다.

(노드에서) 구동되고 있는 (스태틱 파드를 포함한) 컨테이너들을 볼 수 있다.

```shell
# kubelet 이 동작하고 있는 노드에서 이 명령을 수행한다.
crictl ps
CONTAINER       IMAGE                                 CREATED           STATE      NAME    ATTEMPT    POD ID
129fd7d382018   docker.io/library/nginx@sha256:...    11 minutes ago    Running    web     0          34533c6729106
```

> [!NOTE] 참고
`crictl`은 이미지 URI와 SHA-256 체크섬을 출력한다. `NAME`은 다음과 같을 것이다. `docker.io/library/nginx@sha256:0d17b565c37bcbd895e9d92315a05c1c3c9a29f762b011a10c54a66cd53c9b31`

API 서버에서 미러 파드를 볼 수 있다.

```shell
kubectl get pods
NAME         READY   STATUS    RESTARTS        AGE
static-web   1/1     Running   0               2m
```

> [!NOTE] 참고
> API 서버에서 미러 파드를 생성할 수 있는 권한이 kubelet에게 있는지 미리 확인해야 한다. 그렇지 않을 경우 API 서버에 의해서 생성 요청이 거부된다.

스태틱 파드에 있는 [레이블](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/labels) 은 미러 파드로 전파된다. [셀렉터](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/labels/) 등을 통하여 이러한 레이블을 사용할 수 있다.

만약 API 서버로부터 미러 파드를 지우기 위하여 `kubectl` 을 사용하려 해도, kubelet 은 스태틱 파드를 지우지 _않는다._

```shell
kubectl delete pod static-web
pod "static-web" deleted
```

파드가 여전히 구동 중인 것을 볼 수 있다.

```shell
kubectl get pods
NAME         READY   STATUS    RESTARTS   AGE
static-web   1/1     Running   0          4s
```

kubelet 이 구동 중인 노드로 돌아가서 컨테이너를 수동으로 중지할 수 있다. 일정 시간이 지나면, kubelet이 파드를 자동으로 인식하고 다시 시작하는 것을 볼 수 있다.

```shell
# kubelet 이 동작하고 있는 노드에서 이 명령을 수행한다.
crictl stop 129fd7d382018 # 예제를 수행하는 사용자의 컨테이너 ID로 변경한다.
sleep 20
crictl ps
CONTAINER       IMAGE                                 CREATED           STATE      NAME    ATTEMPT    POD ID
89db4553e1eeb   docker.io/library/nginx@sha256:...    19 seconds ago    Running    web     1          34533c6729106
```

## 스태틱 파드의 동적 추가 및 제거[](https://kubernetes.io/ko/docs/tasks/configure-pod-container/static-pod/#%EC%8A%A4%ED%83%9C%ED%8B%B1-%ED%8C%8C%EB%93%9C%EC%9D%98-%EB%8F%99%EC%A0%81-%EC%B6%94%EA%B0%80-%EB%B0%8F-%EC%A0%9C%EA%B1%B0)

실행 중인 kubelet 은 주기적으로, 설정된 디렉터리(예제에서는 `/etc/kubernetes/manifests`)에서 변경 사항을 스캔하고, 이 디렉터리에 새로운 파일이 생성되거나 삭제될 경우, 파드를 생성/삭제 한다.

```shell
# 예제를 수행하는 사용자가 파일시스템이 호스팅하는 스태틱 파드 설정을 사용한다고 가정한다.
# kubelet 이 동작하고 있는 노드에서 이 명령을 수행한다.
#
mv /etc/kubernetes/manifests/static-web.yaml /tmp
sleep 20
crictl ps
# 구동 중인 nginx 컨테이너가 없는 것을 확인한다.
mv /tmp/static-web.yaml  /etc/kubernetes/manifests/
sleep 20
crictl ps
```

```console
CONTAINER       IMAGE                                 CREATED           STATE      NAME    ATTEMPT    POD ID
f427638871c35   docker.io/library/nginx@sha256:...    19 seconds ago    Running
```