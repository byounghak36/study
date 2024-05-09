---
title: K8S_Service_OBJ-ClusterIP
tags:
  - K-PaaS
  - kubernetes
date: 2024_04_21
Modify_Date: 
reference:
---
# K8S_Service_OBJ-ClusterIP

쿠버네티스 내부에서 파드들에 접근할 때 사용합니다. 외부로 파드를 노출하지 않기 때문에 쿠버네티스 클러스터 내부에서만 사용되는 파드에 적합합니다.

### Service.yaml

```yaml
# clusterip-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hostname-svc-clusterip
spec:
  type: ClusterIP
  ports:
  - name: web-port
    port: 8080
    targetPort: 80
  selector:
    app: webserver
    
# hostname.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostname-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      name: my-webserver
      labels:
        app: webserver
    spec:
      containers:
      - name: my-webserver
        image: alicek106/rr-test:echo-hostname
        ports:
        - containerPort: 80
```

- **spec.selector** : 서비스에서 어떠한 라벨을 가지는 파드에 접근할 수 있게 만들 것인지 결정합니다. 위 예시는 app: webserver 라는 라벨을 가지는 파드에 접근할 수 있는 서비스를 생성합니다.
- **spec.ports.port** : 서비스 IP에 접근할 때 사용되는 포트를 설정합니다.
- **spec.ports.targetPort** : **spec.selector** 항목에서 정의한 라벨에 의 접근 대상이 된 파드들이 내부적으로 사용하고 있는 포트를 입력합니다. 즉 containerPort와 같은 값으로 설정했습니다.
- **spec.type** : 서비스의 타입을 나타냅니다. ClusterIP, NodePort, LoadBalancer 등을 설정합니다.

```bash
$ kubectl apply -f clusterip-service.yaml
$ kubectl get service -o wide
NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE    SELECTOR
hostname-svc-clusterip   ClusterIP   10.233.36.78   <none>        8080/TCP   116s   app=webserver
kubernetes               ClusterIP   10.233.0.1     <none>        443/TCP    48d    <none>  
```

서비스가 생성돼 있는것을 확인후 이 서비스를 접근하기 위해서는 위 출력 내용중 CLUSTER-IP 항목의 IP와 PORT(S) 항목의 포트를 통해 요청을 보내면 됩니다.

![[Pasted image 20240417093348.png]]

```bash
$ kubectl run -i --tty --rm debug --image=alicek106/ubuntu:curl --restart=Naver -- bash
root@debug:/# curl 10.233.36.78:8080 --silent | grep Hello
        <p>Hello,  hostname-deployment-7f8f9f9754-ttcvj</p>     </blockquote>
root@debug:/# curl 10.233.36.78:8080 --silent | grep Hello
        <p>Hello,  hostname-deployment-7f8f9f9754-42hm6</p>     </blockquote>
root@debug:/# curl 10.233.36.78:8080 --silent | grep Hello
        <p>Hello,  hostname-deployment-7f8f9f9754-7prbv</p>     </blockquote>
```
- `kubectl run`: Kubernetes 클러스터에서 파드를 실행하는 명령어입니다.
- `-i --tty --rm debug`: `-i` 옵션은 파드를 대화형으로 생성하고, `--tty` 파드에 터미널을 할당합니다. `--rm` 옵션은 파드 실행이 완료되면 파드를 삭제하는 역할을 합니다. `debug`는 파드의 이름을 지정합니다.
- `--image=alicek106/ubuntu:curl`: 파드에서 실행할 컨테이너의 이미지를 지정합니다. 여기서는 `alicek106/ubuntu` 이미지에 `curl` 도구가 포함된 버전을 사용합니다.
- `--restart=Never`: 파드의 재시작 정책을 지정합니다. `Never`로 설정하면 파드가 한 번 실행된 후 종료되면 다시 시작되지 않습니다. 즉, 파드는 한 번 실행되고 작업이 완료되면 종료됩니다.
- `-- bash`: 이 부분은 파드 내부의 쉘을 실행하도록 지정하는 부분입니다. `--`는 이후의 명령어가 파드 내부의 쉘로 전달됨을 의미하며, `bash`는 실행할 쉘의 종류를 지정합니다.

위와 같이 **spec.selector** 로 지정된 pod에 접근이 가능한 것을 확인할 수 있습니다. 단 위에서 생성한 서비스는 ClusterIP 타입이기에 외부에서는 접근 할 수 없습니다. 클러스터 내부에서 사용되는 파드라면 상관없지만 외부에 노출한다면 **NodePort**나 **LoadBalancer** 타입을 생성해야 합니다.

> [!NOTE] 엔드포인트(endpoint)
> **spec.selector** 로 서비스와 파드의 라벨이 매칭돼 연결되면 자동으로 엔드포인트(endpoint)라는 별도의 오브젝트를 생성합니다.
> ```bash
> $ kubectl get endpoints
> NAME                     ENDPOINTS                                             AGE
> hostname-svc-clusterip   10.233.105.182:80,10.233.116.62:80,10.233.125.18:80   16m
> kubernetes               10.101.0.3:6443,10.101.0.5:6443,10.101.0.7:6443       48d
> ```
> 엔드포인트 오브젝트는 서비스가 가리키고 있는 도착점을 나타냅니다. 서비스를 이용해 파드를 연결한다면 자동으로 생성됩니다.
