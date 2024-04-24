---
title: 무제 파일
tags: 
date: 2024_04_25
Modify_Date: 
reference:
---


  노드 리부팅시
```
Events:
  Type     Reason        Age                    From             Message
  ----     ------        ----                   ----             -------
  Warning  NodeNotReady  25m                    node-controller  Node is not ready
  Warning  FailedMount   5m33s (x5 over 5m41s)  kubelet          MountVolume.MountDevice failed for volume "pvc-d5685eee-7f6e-489d-b660-3b4e645c1b62" : kubernetes.io/csi: attacher.MountDevice failed to create newCsiDriverClient: driver name rook-ceph.cephfs.csi.ceph.com not found in the list of registered CSI drivers
  Warning  FailedMount   3m38s                  kubelet          Unable to attach or mount volumes: unmounted volumes=[data], unattached volumes=[], failed to process volumes=[]: timed out waiting for the condition
  Warning  FailedMount   3m25s                  kubelet          MountVolume.MountDevice failed for volume "pvc-d5685eee-7f6e-489d-b660-3b4e645c1b62" : rpc error: code = DeadlineExceeded desc = context deadline exceeded
  Warning  FailedMount   3m9s                   kubelet          MountVolume.MountDevice failed for volume "pvc-d5685eee-7f6e-489d-b660-3b4e645c1b62" : rpc error: code = Aborted desc = an operation with the given Volume ID 0001-0009-rook-ceph-0000000000000001-fd284eb5-f53e-4f38-9f71-fd7ace12a890 already exists
  Normal   Pulling       2m36s                  kubelet          Pulling image "hashicorp/vault:1.14.0"
  Normal   Pulled        2m32s                  kubelet          Successfully pulled image "hashicorp/vault:1.14.0" in 2.177658326s (4.075995499s including waiting)
  Normal   Created       2m32s                  kubelet          Created container vault
  Normal   Started       2m32s                  kubelet          Started container vault
  Warning  Unhealthy     37s (x24 over 2m27s)   kubelet          Readiness probe failed: Key                Value
---                -----
```
