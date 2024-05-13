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

## ReplicationController
기본적인 작성방법은 Pod 작성할때와 동일하다.[[K8S_Pod-YAML_작성법]]
kind 를 ReplicationController로 변경한 후 spec.template 하위에 Pod의 metadata, spec을 기입한다.

![[K8S_replication_yaml.png]]

> 위의 경우는 ReplicationController로 현재는 ReplicaSet 으로 변경되었다.

## ReplicaSet
![[Pasted image 20240513165514.png]]

사진으로 보다시피 ReplicaSet 의 경우는 **apiVersion이 apps/v1** 으로 변경되었으며 하단의 selector 가 추가되었다. 해당 부분에 matchLabels 등을 통하여 어떤 Pod를 복제할것인지 명시하여야 한다.