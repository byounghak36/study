---
title: 무제 파일
tags:
  - kubernetes
  - K8S_ReplicaSet
  - yaml
date: 2024_05_13
Modify_Date: 
reference: 
link:
---
## 작성방법

기본적인 작성방법은 Pod 작성할때와 동일하다.[[K8S_Pod-YAML_작성법]]
kind 를 ReplicationController로 변경한 후 spec.template 하위에 Pod의 metadata, spec을 기입한다.

![[K8S_replication_yaml.png]]