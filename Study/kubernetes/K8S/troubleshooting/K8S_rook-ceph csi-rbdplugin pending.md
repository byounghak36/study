---
title: K8S_rook-ceph csi-rbdplugin pending
tags:
  - kubernetes
  - k8s_troubleshooting
  - rook-ceph
date: 2024_06_05
reference: 
link:
---
# csi-rbdplugin pending

Rook-Ceph 배포 이후에 아래와 같은 이벤트 로그가 출력 되면서, ceph blockstroage 를 생성하지 못하게 되었다.
```shell
Warning BackOff 32m (x6318 over 22h) kubelet Back-off restarting failed container csi-rbdplugin in pod csi-rbdplugin-z5lqj_rook-ceph(349e84d0-a9f3-4e6c-8071-553e09b96c3b)
Warning BackOff 2m30s (x5783 over 22h) kubelet Back-off restarting failed container driver-registrar in pod csi-rbdplugin-z5lqj_rook-ceph(349e84d0-a9f3-4e6c-8071-553e09b96c3b)
```


해당 오류 메시지는 Kubernetes에서 특정 Pod 내의 컨테이너가 반복적으로 실패하여 재시작되고 있는 상황을 나타낸다.
여기서 `csi-rbdplugin` 및 `driver-registrar` 컨테이너가 지속적으로 실패하고 있으며, kubelet이 이를 감지하고 재시작을 시도하고 있지만, 계속 실패하고 있다는 것을 의미합니다. 
몇가지를 후보에 둘 수 있다.

1. **컨테이너 이미지 문제**: 잘못된 이미지 태그, 이미지가 존재하지 않거나 손상된 경우.
2. **환경 설정 문제**: 환경 변수, 설정 파일, 또는 비밀 값이 잘못되었거나 누락된 경우.
3. **자원 부족**: 클러스터 내에서 메모리 또는 CPU 자원이 부족한 경우.
4. **의존성 문제**: 컨테이너가 의존하는 서비스 또는 자원이 사용 불가능한 경우.
5. **컨테이너 내부 오류**: 컨테이너 내 애플리케이션 코드에 문제가 있는 경우 (예: 예기치 않은 종료, 크래시 루프).

이 문제를 해결하기 위해 로그를 확인했다.

### 1. 로그 확인

```shell
kubectl logs csi-rbdplugin-z5lqj -n rook-ceph -c csi-rbdplugin kubectl logs csi-rbdplugin-z5lqj -n rook-ceph -c driver-registrar
ubuntu@master01:~/rook/deploy/examples/csi/cephfs$ kubectl logs csi-rbdplugin-z5lqj -n rook-ceph -c csi-rbdplugin E0605 05:08:25.655886 785906 rbd_util.go:303] modprobe failed (an error (exit status 1) occurred while running modprobe args: [rbd]): "modprobe: ERROR: could not insert 'rbd': Exec format error\n" F0605 05:08:25.656513 785906 driver.go:154] an error (exit status 1) occurred while running modprobe args: [rbd]
```

modprobe: ERROR: could not insert 'rbd': Exec format error\n

rdb 모듈을 로드 할 수 없다고 한다... 생각해보니 배포시에 rdb 모듈을 import 하지 않았다.
### 2. 조치
```shell
ubuntu@master01:~$ sudo modprobe rbd
ubuntu@master02:~$ sudo modprobe rbd
ubuntu@master03:~$ sudo modprobe rbd
ubuntu@worker01:~$ sudo modprobe rbd
.
.
.
```

모두 모듈을 불러오고 csi-rbdplugin 을 재시작하니 시스템이 정상적으로 동작하기 시작했다.