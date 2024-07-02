---
title: Network_ACL
tags:
  - NHN_Network_ALC
date: 2024_06_25
reference: 
link:
  - https://docs.nhncloud.com/ko/Network/Network%20ACL/ko/overview/
---
# 목차
---
- [[#Network > Network ACL > 개요|Network > Network ACL > 개요]]
- [[#ACL 기능|ACL 기능]]
	- [[#ACL 기능#ACL|ACL]]
	- [[#ACL 기능#ACL Rule|ACL Rule]]
	- [[#ACL 기능#ACL Binding|ACL Binding]]

## Network > Network ACL > 개요

NHN Cloud는 Network ACL 기능을 제공합니다. 이를 이용하면 protocol, ip, port 별로 접근 제어가 가능해집니다.

## ACL 기능

네트워크로 유입되는 패킷을 제어하려면 ACL 기능을 이용할 수 있습니다. 이 기능은 [보안 그룹](https://docs.nhncloud.com/ko/Network/VPC/ko/console-guide/#_8)과 구분되는 기능으로써 차이점은 다음과 같습니다.

> [!NOTE] 
> #### 보안 그룹과 Network ACL 기능 비교
> 
> |구분|보안 그룹|Network ACL|비고|
> |---|---|---|---|
> |제어 대상|인스턴스|네트워크, 인스턴스||
> |설정 대상|Protocol, IP, 포트 설정|Protocol, IP, 포트 설정|ACL은 black list, white list 선택적으로 운영 가능|
> |제어 트래픽|유입/유출 트래픽  <br>선택 가능|src, dst 주소 선택 가능||
> |접근 제어 타입|허용 정책만 설정|허용 또는 차단 정책 선택 가능||

**유입/유출 트래픽에서 Network ACL 설정이 보안 그룹 설정보다 먼저 적용**됩니다. Network ACL 설정에서 허용되었더라도, 보안 그룹에서 차단될 수 있으므로 두 곳 모두 확인을 해야 합니다.

Network ACL 기능을 이용하려면 다음 사항을 설정해야 합니다.

### ACL

- 한 프로젝트에 최대 10개의 ACL을 생성할 수 있습니다.
- 속성은 이름, 메모입니다.

### ACL Rule

- 하나의 프로젝트에 최대 100개의 rule을 생성할 수 있습니다.
- order 번호에 따라서 priority를 가지고 순서대로 적용됩니다. 작은 번호가 높은 priority를 가집니다.
- '허용(Allow)': 해당 rule과 매칭되는 접근은 **허용**합니다.
- '차단(Deny)': 해당 rule과 매칭되는 접근은 **차단**합니다.
- 하나의 접근제어 대상은 IP 주소 또는 CIDR 형식의 IP 주소 범위를 가질 수 있습니다. CIDR 형식의 IP 주소 범위를 입력하면 해당 네트워크 내에서 입력한 대역이 접근제어 대상에 포함됩니다.
- 프로토콜을 지정할 경우 하나의 포트 혹은 포트 범위를 가질 수 있습니다.
- src와 dst에 대해 rule을 항상 짝으로 설정해 주어야 합니다.

### ACL Binding

- 하나의 ACL에 binding 될 수 있는 network의 수는 최대 VPC 개수만큼입니다.
- 하나의 ACL은 여러 Network에 적용할 수 있습니다.
- 하나의 Network에는 하나의 ACL을 적용할 수 있습니다.

> [!NOTE]
> #### Network와 ACL 동작
> - Network를 삭제하면 ACL binding이 삭제됩니다. ACL은 삭제되지 않습니다.
> - ACL에 binding 된 network이 있으면 ACL을 삭제할 수 없습니다.
> - ACL rule을 추가하거나 삭제하면 binding 된 모든 network에 해당 내역이 반영됩니다.

