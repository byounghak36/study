---
title: K8S_Plugin_rook-ceph_osd 제거 및 추가
tags:
  - rook-ceph
date: 2024_05_31
reference:
  - https://velog.io/@numerok/rook-ceph-osd-%EC%A0%9C%EA%B1%B0-%EB%B0%8F-%EC%B6%94%EA%B0%80
link:
---
# 0. 발단
아래와 같이 pods 한개가 pending 에 빠진상태
```shell
rook-ceph-osd-0-7f7d8c69cb-4pfh7                     2/2     Running                       0          2d1h
rook-ceph-osd-1-785dd669b6-wx75r                     0/2     Pending                       0          30m
rook-ceph-osd-2-97cf58d69-lpjqk                      2/2     Running                       2          21d
rook-ceph-osd-3-66444d8fdf-7dcrc                     2/2     Running                       0          23h
```


osd 제거
```shell
bash-4.4$ ceph auth list
bash-4.4$ ceph osd out osd.1
marked out osd.1.
bash-4.4$ ceph osd df
ID  CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA     OMAP     META     AVAIL    %USE  VAR   PGS  STATUS
 1    hdd  0.09769         0      0 B      0 B      0 B      0 B      0 B      0 B     0     0    0    down
 0    hdd  0.09769   1.00000  100 GiB  2.9 GiB  2.5 GiB  4.1 MiB  423 MiB   97 GiB  2.90  0.86   49      up
 2    hdd  0.09769   1.00000  100 GiB  3.4 GiB  2.9 GiB  4.1 MiB  521 MiB   97 GiB  3.38  1.00   49      up
 3    hdd  0.09769   1.00000  100 GiB  3.8 GiB  3.6 GiB  5.4 MiB  243 MiB   96 GiB  3.84  1.14   49      up
                       TOTAL  300 GiB   10 GiB  9.0 GiB   14 MiB  1.2 GiB  290 GiB  3.38
```


replicas 조정
```shell
kubectl scale --replicas=0 -n rook-ceph deploy/rook-ceph-osd-1
```