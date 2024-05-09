---
title: K8S_Service_OBJ_ingress-nginx-contorller
tags:
  - kubernetes
date: 2024_05_09
Modify_Date: 
reference: 
link:
---
### Ingress란
- k8s의 Ingress는 외부에서 k8s cluster 내부로 들어오는 네트워크 요청 즉, Ingress 트래픽을 어떻게 처리할지 정의한다.
- 다시 말하면, Ingress는 외부에서 k8s에서 실행 중인 Deployment와 Service에 접근하기 위한, 일종의 관문(Gateway) 같은 역할을 담당한다.
- Ingress를 사용하지 않았다고 가정했을 때, 외부 요청을 처리할 수 있는 선택지는 NodePort, ExternalIP 등이 있다.
- 그러나 이러한 방법들은 일반적으로 Layer4(TCP,UDP)에서의 요청을 처리하며, 네트워크 요청에 대한 세부적인 처리 로직을 구현하기는 아무래도 한계가 있다.
