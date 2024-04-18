
- 클러스터 내부 및 외부 통신이 가능한 Service 타입이다.
- **NodePort** 는 외부 트래픽을 전달을 받을 수 있고, **NodePort** 는 **CluseterIP** 를 wrapping 하는 방식이기 때문에 종장의 흐름은 결국 **CluseterIP**  비슷한 방식으로 이루어진다.
- **NodePort** 는 이름 그대로 노드의 포트를 사용한다. (30000-32767)
- 그리고 클러스터를 구성하는 각각의 Node에 동일한 포트를 열게 되는데, 이렇게 열린 포트를 통해서 Node마다 외부 트래픽을 받고 => 그게 결국 **CluseterIP** 로 모인 후 다시 로드를 분산시키는 방식이다.
### Service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: hostname-svc-nodeport
spec:
  type: NodePort
  ports:
  - name: webserver
    port: 8080
    targetPort: 80
  selector:
    app: webserver
```

ClusterIP 타입의 서비스를 생성했을 때 yaml 파일과 **spec.type** 항목을 NodePort 로 설정한 점을 제외하고는 모두 동일합니다. NodePort와 ClusterIP는 동작 방법이 다른 것일 뿐, 동일한 서비스 리소스이기 때문에 다른 설정은 모두 같습니다.

> [!NOTE] NodePort Port 지정
> 각 노드에서 개방되는 포트는 기본적으로 30000~32768 중에 랜덤으로 선택되지만, nodePort 항목을 정의하면 원하는 포트를 선택할 수도 있습니다.
> ```yaml
> ~
>   port : 8080
>   targetPort : 80
>   nodePort : 31000  
> ~
> ```

```bash
$ kubectl apply -f nodeport-service.yaml
service/hostname-svc-nodeport configured
$ kubectl get service
NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hostname-svc-nodeport   NodePort    10.233.60.61   <none>        8080:31333/TCP   76s
kubernetes              ClusterIP   10.233.0.1     <none>        443/TCP          48d
```

서비스 목록을 확인해보면 NodePort 타입의 서비스가 생성되고 PORT(S) 항목에 출력된 31333라는 숫자는 모든 노드에서 동일하게 접근할 수 있는 포트를 의미합니다. 즉, 클러스터의 모든 노드에 내부 IP 또는 외부 IP 를 통해 31333 포트로 접근하면 동일한 서비스에 연결 할 수 있습니다.

```bash
$ kubectl get nodes -o wide
NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
master1   Ready    control-plane   48d   v1.27.5   10.101.0.3    <none>        Ubuntu 22.04.4 LTS   5.15.0-97-generic    cri-o://1.27.1
master2   Ready    control-plane   48d   v1.27.5   10.101.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-101-generic   cri-o://1.27.1
master3   Ready    control-plane   48d   v1.27.5   10.101.0.7    <none>        Ubuntu 22.04.4 LTS   5.15.0-97-generic    cri-o://1.27.1
worker1   Ready    <none>          48d   v1.27.5   10.101.0.13   <none>        Ubuntu 22.04.4 LTS   5.15.0-97-generic    cri-o://1.27.1
worker2   Ready    <none>          48d   v1.27.5   10.101.0.15   <none>        Ubuntu 22.04.4 LTS   5.15.0-101-generic   cri-o://1.27.1
worker3   Ready    <none>          48d   v1.27.5   10.101.0.21   <none>        Ubuntu 22.04.4 LTS   5.15.0-101-generic   cri-o://1.27.1
$ curl 10.101.0.3:31333 --silent | grep Hello
        <p>Hello,  hostname-deployment-7f8f9f9754-ttcvj</p>     </blockquote>
$ curl 10.101.0.3:31333 --silent | grep Hello
        <p>Hello,  hostname-deployment-7f8f9f9754-42hm6</p>     </blockquote>
$ curl 10.101.0.3:31333 --silent | grep Hello
        <p>Hello,  hostname-deployment-7f8f9f9754-7prbv</p>     </blockquote>
```

한가지 특이한점은 타입을 NodePort로 지정했음에도 Service 오브젝트에 ClusterIP 가 생성된것을 확인 할 수 있습니다. 이는 NodePort 타입의 서비스가 ClusterIP 의 기능을 포함하고 있기 때문입니다. 즉 NodePort 타입의 서비스는 내부 네트워크와 외부 네트워크 양쪽에서 접근할 수 있습니다.

![[Pasted image 20240417103730.png]]

하지만 실제 운영 환경에서 NodePort로 서비스를 외부에 제공하는 경우는 많지 않습니다. NodePort를 80 또는 443으로 설정하기에는 적절하지 않으며, SSL 인증서 적용, 라우팅과 같은복잡한 설정을 서비스에 적용하기가 어렵기 때문입니다. 따라서 NodePort를 통해 서비스를 직접 외부로 제공하기보다는 인그레스(Ingress)를 이용하여 간접적으로 사용되는 경우가 많습니다.


