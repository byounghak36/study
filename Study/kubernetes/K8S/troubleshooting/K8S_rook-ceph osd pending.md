---
title: 무제 파일
tags:
  - k8s_troubleshooting
  - rook-ceph
  - kubernetes
date: 2024_06_04
reference: 
link:
---
OSD Pod의 pending 이슈

- Node: worker01
- Pod: rook-ceph-osd-3
- Event:

```shell
0/7 nodes are available: 3 node(s) didn't match Pod's node affinity/selector, 4 node(s) had untolerated taint {nvidia.com/gpu: present}. preemption: 0/7 nodes are available: 7 Preemption is not helpful for scheduling..
```

위 event 로그는 GPU Operator를 배포하면서 GPU가 장착된 worker01~04 노드에 taint가 정의되면서 발생한 이슈,
GPU Operator 플러그인도 taint & toleration을 사용하고 rook-ceph도 taint & toleration을 사용하면서 발생한 노드 선점 이슈였음

임시방편으로 node의 아래 taint를 삭제

```yaml
taints:
- key: nvidia.com/gpu
- value: present
- effect: NoSchedule
```

이후 rook-ceph-osd-3를 재생성하여 노드에 적재한 뒤 taint를 복구시키는 방법으로 조치