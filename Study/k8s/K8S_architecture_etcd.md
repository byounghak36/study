---
title: K8S_architecture_etcd
tags:
  - kubernetes
date: 2024_04_25
Modify_Date: 
reference:
---
# K8S_architecture_etcd

모든 오브젝트(Pod, Replicas, Service, Secret 등) 는 API 서버가 다시 시작되거나 실패하더라도 유지하기 위해 매니페스트가 영구적으로 저장될 필요가 있습니다. 이를 위해 쿠버네티스는 빠르고, 분산되어 저장되며, 키-값 구조의 저장소를 제공하는 etcd를 사용합니다. 