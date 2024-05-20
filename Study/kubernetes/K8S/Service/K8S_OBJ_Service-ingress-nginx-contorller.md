---
title: K8S_Service_OBJ_ingress-nginx-contorller
tags:
  - kubernetes
  - K8S_OBJ_Service
date: 2024_05_09
Modify_Date: 
reference: 
link:
---
### 1 ingress-nginx 개요
인그레스를 사용하면 L7의 웹 요청을 해석해서 단일 IP, 단일 포트로 다수의 도메인과 서비스로 연결할 수 있습니다. 이 방법을 사용하면 웹페이지의 도메인은 같지만 다른 앱을 사용하는 것도 가능하게 합니다. 하지만 쿠버네티스에서 기본적으로 지원하는 인그레스 오브젝트는 클라우드 환경이 아니면 사용할 수 없습다. 클라우드에서 인그레스를 생성하면 외부에 게이트웨이를 생성하고 각 기능에 맞게 서비스에 연결합니다. GCP의 경우에는 외부 게이트웨이에 L7 규칙이 적용돼 있습니다. 이 포스트에 있는 nginx-ingress를 사용해보기 전에 GCP에서 제공하는 ingress를 한번 써보시길 권장합니다.

HTTP(S) 부하 분산용 GKE 인그레스
- [https://cloud.google.com/kubernetes-engine/docs/concepts/ingress?hl=ko](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress?hl=ko)

![](https://mblogthumb-phinf.pstatic.net/MjAyMDA0MDNfMjYx/MDAxNTg1ODk1NDA5Njcw.5WU_cU19HT52XhHXLo4wKHaqQaRsgQ1N-C2eOkzXK2kg.5m_jdfuA_zqPABl2arG40FjUPm83w41fqsn3v5XV8xkg.PNG.isc0304/image.png?type=w800)

​
여기서는 로컬에서 인그레스를 사용할 수 있는 ingress-nginx를 설치하고 쿠버네티스에 포드 형태로 띄워서 설정하는 방법을 알아봅니다. nginx-ingress를 포드로 떠있으면서 다시 서비스로 연결할 수 있는 역할을 수행합니다.

![](https://mblogthumb-phinf.pstatic.net/MjAyMDA0MDNfNjMg/MDAxNTg1OTAyMTEyNDEw.KVXZOubyS0p1CRw4uFpMULKiJDcBgYjpHNr8Tl8aQ08g.79NKdfVdoUE6ABJPlQPxEvaiwCZaM2RnMV6pAXVKN-gg.PNG.isc0304/image.png?type=w800)

Enterprise-grade application delivery for Kubernetes
그림출처: [https://www.nginx.com/products/nginx/kubernetes-ingress-controller/](https://www.nginx.com/products/nginx/kubernetes-ingress-controller/)

### 2 Ingress-nginx 설치
ingress-nginx를 직접 쿠버네티스에 설치하고 ingress가 잘 실행되는지 테스트해봅시다. 분석했던 내용처럼 namespace가 생성되고 configmap 3개, 서비스어카운트에 클러스터롤과 롤 권한이 부여됩니다. 마지막으로 nginx-ingress-controller라는 이름으로 디플로이먼트가 시작됩니다.
```bash
git clone https://github.com/kubernetes/ingress-nginx/ kubectl apply -k `pwd`/ingress-nginx/deploy/static/provider/baremetal/
```
ingress-nginx 네임스페이스의 포드를 조회해 잘 도는지 확인합니다. 당연히 지금은 ingress 객체를 만들지 않았기 때문에 포워딩 기능이 실행되고 있지는 않습니다.

```bash
$ kubectl get pod -n ingress-nginx NAME READY STATUS RESTARTS AGE ingress-nginx-admission-create-6drjg 0/1 Completed 0 32s ingress-nginx-admission-patch-5tlgm 0/1 Completed 0 31s ingress-nginx-controller-5844948947-j6bzt 1/1 Running 0 35s
```

현재 오류 때문에 잘 동작하지 않는 webhook 기능은 잠시 제거합니다. 현재는 기능이 있으면 ingress를 생성할 때 특정 포드를 찾는데 실패하며 오류가 발생합니다. (2021.9.26 기준)

```bash
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io ingress-nginx-admission
```
​

함께 만들어진 nginx-ingress-controller의 서비스인 노드포트를 확인합니다. 여기서 포트는 30703와 30955입니다. 443 포트는 ingress를 생성했을 때 tls를 쓴 경우에 사용할 수 있습니다. 여기서는 80포트로 접속할 것이니 앞의 번호를 사용하면 됩니다.

$ kubectl get svc -n ingress-nginx NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE ingress-nginx-controller NodePort 10.107.27.27 <none> 80:30703/TCP,443:30955/TCP 138m ingress-nginx-controller-admission ClusterIP 10.97.210.82 <none> 443/TCP 138m

​

​

3 http-go 서비스 설치

​

가장 먼저 할일은 웹서비스를 하나 띄우고 그 서비스가 잘 서비스되는지 테스트합니다. ingress는 그 다음에 설치합니다. http-go는 go로 작성했으며 8080포트로 웹서비스를 하는 간단한 이미지입니다. 서비스는 NodePort로 열어줍니다.

kubectl create deployment http-go --image=gasbugs/http-go:ingress # 인그레스 테스트용 http-go kubectl expose deployment http-go --port=80 --target-port=8080

​

​

4 Ingress 룰 생성

이제 ingress를 생성해 ingress-nginx와 http-go를 연결할 룰을 만들어 줍니다. 다음 그림처럼 룰을 만들어야 외부에서 요청이 왔을 때 인그레스가 http-go로 포워딩해줍니다. ingress의 룰은 단순합니다. 도메인과 경로로 규칙을 지정하는데 여기서는 gasbugs.com/hostsname로 ingress에 요청이 들어오면 http-go로 연결해줍니다.

![](https://mblogthumb-phinf.pstatic.net/MjAyMDA0MDNfMTMy/MDAxNTg1OTAxMzM5NTY5.KA-K1td4oNer_wBCXIIA5kwIcduaMyWBBw9Z9M3AOFgg.3SfSNlmUcUbV_SiIkMOME84T-rovhQgtaxEL8fLv_j8g.PNG.isc0304/image.png?type=w800)

​

내용을 작성할 때는 다음을 주의해야 합니다.

- http-go와 동일한 네임스페이스에 작성해야 함

- 앞서 생성한 서비스 이름이 serviceName과 동일해야 함

- servicePort는 서비스가 동작하는 포트를 의미해야 함

(서비스의 포트와 포드의 포트가 다른 경우에도 서비스 포트를 적습니다)

​

도메인 이름을 설정할 수 있지만 여기서는 제외합니다. 경로는 Exact 타입을 활용해 /welcom/test와 정확히 일치하는 url만 http-go 서비스로 넘겨주도록 설정합니다. 경로를 사용하도록 만들었기 때문에 반드시http://<ip>/welcome/tets로 요청해야만 http-go로 연결됩니다.

cat <<EOF | kubectl apply -f - apiVersion: networking.k8s.io/v1 kind: Ingress metadata: name: http-go-ingress annotations: kubernetes.io/ingress.class: nginx nginx.ingress.kubernetes.io/rewrite-target: /welcome/test spec: rules: - http: paths: - pathType: Exact path: /welcome/test backend: service: name: http-go port: number: 80 EOF

​

​

5 인그레스 정상 동작 테스트

노드의 30703로 접속을 시도해봅니다. 여기서는 마스터 노드에서 작업을 진행하였기에 127.0.0.1:31042로 요청을 수행합니다. 경로도 정확하게 입력해야 합니다.

# curl 127.0.0.1:30703/welcome/test Welcome! http-go-79c5db8577-c5rld