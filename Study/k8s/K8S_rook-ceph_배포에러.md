---
title: K8S_rook-ceph_배포에러
tags:
  - kubernetes
  - K-PaaS
  - rook-ceph
date: 2024_05_10
Modify_Date: 
reference: 
link:
  - https://rook.io/docs/rook/v1.9/Storage-Configuration/ceph-teardown/?fbclid=IwZXh0bgNhZW0CMTAAAR1MwR7KdPVXFbqBLxvYnsx4kEH5Cz_h9etKIMeABGpcTrujWxH-7w3KUpM_aem_Aem4mNqbuopEEdpQNwcM-LJw2_gA1i3ULm4lkncpMfNuTZS1b_cQ7bpqiMmgeX-20otSl-V0jYIThbuQuvXXjLTn#cleaning-up-a-cluster
---
  -=432`

1) 에러나는 rook-ceph 파드에 대해서 삭제 진행해 주시기 바랍니다. 
삭제시 rook-ceph-osd-prepare-master01-*****, rook-ceph-osd-prepare-master02-***** init 컨테이너부터 차례대로 제대로 올라오는지 확인 부탁드립니다.

```bash
$ kubectl delete pod rook-ceph-osd-0-5c4f46949f-sslwh -n rook-ceph
$ kubectl delete pod rook-ceph-osd-1-f4fff7cdb-k8q4m -n rook-ceph
```

2) 파드를 재배포후 계속해서 에러가 발생할 경우 rook-ceph 재배포를 시도해 주시기 바랍니다. rook-ceph 재배포시 사용하고 있는 스토리지가 먼저 삭제가 진행이 되어야 하므로 사용하고 있는 컨테이너 플래폼 포털, 서비스를 우선 삭제해 주시기 바랍니다.(삭제 순서 서비스(소스컨트롤, 파이프라인 순서 상관 없음) -> 포털)

### 컨테이너 플랫폼 파이프라인 서비스를 사용할 경우
```bash
$ cd ~/workspace/container-platform/cp-pipeline-deployment/script
$ chmod +x uninstall-cp-pipeline.sh
$ ./uninstall-cp-pipeline.sh
```

### 컨테이너 플랫폼 소스컨트롤 서비스를 사용할 경우

```bash
$ cd ~/workspace/container-platform/cp-source-control-deployment/script
$ chmod +x uninstall-cp-source-control.sh
$ ./uninstall-cp-source-control.sh
```

### 컨테이너 플랫폼 포털 사용할 경우

```bash
$ cd ~/workspace/container-platform/cp-portal-deployment/script
$ chmod +x uninstall-cp-portal.sh
$ ./uninstall-cp-portal.sh

```

### Rook-Ceph 삭제

```bash
$ kubectl -n rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
$ kubectl -n rook-ceph delete cephcluster rook-ceph
$ kubectl delete -f ~/cp-deployment/applications/rook-1.12.3/deploy/examples/operator.yaml
$ kubectl delete -f ~/cp-deployment/applications/rook-1.12.3/deploy/examples/common.yaml
$ kubectl delete -f ~/cp-deployment/applications/rook-1.12.3/deploy/examples/crds.yaml
```

### 디스크 확인

```bash
lsblk -f
```

### ceph_bluestore 설정된 디스크 확인

```bash
vdb     ceph_bluestore
```

### 초기화 (추가 볼륨이 할당된 모든 인스턴스에서 실행)

```bash
$ DISK="/dev/<<<DATADIR NAME으로 수정>>>"
$ sgdisk --zap-all $DISK
$ dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
$ blkdiscard $DISK
$ partprobe $DISK
```

### 파일 생성

```bash
$ vi ~/cp-deployment/standalone/playbooks/cluster-storage.yml
- hosts: kube_control_plane
  gather_facts: False
  any_errors_fatal: "{{ any_errors_fatal | default(true) }}"
  environment: "{{ proxy_disable_env }}"
  roles:
    - { role: kubespray-defaults }
    - { role: cp/storage }
```

### 배포 실행

```bash
$ cd ~/cp-deployment/standalone
$ ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root playbooks/cluster-storage.yml
```

