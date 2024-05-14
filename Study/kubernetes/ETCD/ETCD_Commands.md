---
title: ETCD - Commands
tags:
  - etcd
  - kubernetes
date: 2024_05_12
Modify_Date: 
reference: 
link:
---
ETCD - Commands (Optional)

(Optional) Additional information about ETCDCTL Utility  
  
ETCDCTL은 ETCD와 상호작용하는 데 사용되는 CLI 도구입니다.

ETCDCTL은 2가지 API 버전인 버전 2와 버전 3을 사용하여 ETCD 서버와 상호작용할 수 있습니다. 기본적으로 버전 2를 사용하도록 설정되어 있습니다. 각 버전에는 서로 다른 명령 세트가 있습니다.

ETCDCTL 버전 2는 다음 명령어를 지원합니다.

1. etcdctl backup
2. etcdctl cluster-health
3. etcdctl mk
4. etcdctl mkdir
5. etcdctl set

버전 3에서는 명령이 다릅니다.

1. etcdctl snapshot save 
2. etcdctl endpoint health
3. etcdctl get
4. etcdctl put

올바른 버전의 API를 설정하려면 환경 변수 ETCDCTL_API 명령어를 설정하세요.

`export ETCDCTL_API=3`

API 버전이 설정되지 않은 경우 버전 2로 설정된 것으로 간주됩니다. 그리고 위에 나열된 버전 3 명령은 작동하지 않습니다. API 버전이 버전 3으로 설정되면 위에 나열된 버전 2 명령이 작동하지 않습니다.

그 외에도 ETCDCTL이 ETCD API 서버에 인증할 수 있도록 인증서 파일 경로도 지정해야 합니다. 인증서 파일은 다음 경로의 etcd-master 에서 사용할 수 있습니다. 이 과정의 보안 섹션에서 인증서에 대해 자세히 설명합니다. 따라서 이것이 복잡해 보이더라도 걱정하지 마세요.

1. --cacert /etc/kubernetes/pki/etcd/ca.crt     
2. --cert /etc/kubernetes/pki/etcd/server.crt     
3. --key /etc/kubernetes/pki/etcd/server.key

따라서 이전 비디오에서 보여드린 명령이 작동하려면 ETCDCTL API 버전과 인증서 파일 경로를 지정해야 합니다. 아래는 최종 형태입니다.

1. kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key"