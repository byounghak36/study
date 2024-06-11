---
title: 패키지 에러로 apt 미작동
tags:
  - ubuntu
  - apt
date: 2024_05_13
Modify_Date: 
reference: 
link:
---

## 에러문구
```bash
<package name> 패키지를 다시 설치해야 하지만, 이 패키지의 아카이브를 찾을 수 없습니다.
<package name>  needs to be reinstalled, but I can't find an archive for it.
```

위 상황에 봉착하게 되면 모든 apt 관련 명령어들이 먹통이 되어 난감해진다.
아래 답변을 따라 해결 했다.
링크 : https://askubuntu.com/questions/122699/how-to-remove-package-in-bad-state-software-center-freezes-no-synaptic

## 해결

```bash
sudo cp /var/lib/dpkg/status /var/lib/dpkg/status.bkup
vim /var/lib/dpkg/status ## 문제 패키지 확인하여 삭제
apt update
```