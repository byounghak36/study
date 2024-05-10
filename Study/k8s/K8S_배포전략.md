---
title: 무제 파일
tags:
  - kubernetes
  - deploy
date: 2024_05_10
Modify_Date: 
reference: 
link:
---
# 개념

쿠버네티스는 서비스의 무중단 업데이트를 위해 3가지 배포 방식을 지원

롤링 업데이트 : 정해진 비율만큼의 파드만 점진적으로 배포![](https://velog.velcdn.com/images/_zero_/post/157158b2-329d-4989-b060-53b1a48762cf/image.png)

블루/그린 : ver 1.0과 ver 2.0을 구성해놓고, 트래픽을 ver 2.0으로 전환![](https://velog.velcdn.com/images/_zero_/post/ba04e832-70d0-4525-b738-63d545d2822d/image.png)![](https://velog.velcdn.com/images/_zero_/post/e38c2f42-0588-4615-85d4-b823075cc82e/image.png)

카나리 : ver 2.0을 일부만 배포하고, 트래픽도 일부만 ver 2.0으로 전환. 배포에 문제가 없을 경우 ver 2.0을 점진적으로 배포 및 트래픽 전환  
![](https://velog.velcdn.com/images/_zero_/post/98196874-96c1-437c-9953-559f95bf11b0/image.png)

쿠버네티스는 롤링 업데이트를 디폴트 배포 전략으로 설정
한 배포 이후 장애 시 복구를 위해 이전 버전으로 되돌리는 롤백 지원