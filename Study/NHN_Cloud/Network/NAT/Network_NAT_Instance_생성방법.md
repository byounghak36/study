---
title: Network_NAT_Instance_생성방법
tags: 
date: 2024_07_02
reference:
  - https://base-on.tistory.com/525
link:
---
## 환경구성

### 인스턴스
- nat-instance
	- 10.0.1.0 대역 - 인터넷게이트웨이가 있음 / Network > network interface > 할당 받은10.0.1.0 대역의 아이피 "소스/대상 확인 비활성화"
- private-instance
	- 10.0.0.0 대역 : 인터넷 게이트웨이 없음 / Network > routing > 0.0.0.0/0 으로 nat-instance 설정

## 실습

### 1. VPC 생성 

![](https://blog.kakaocdn.net/dn/bhr98o/btseyTZYrRH/biKbZThXEIXTnUiZkPgRk0/img.png)

### 2. 서브넷 생성

![](https://blog.kakaocdn.net/dn/cyybrc/btset6lFKKq/8MvV95a4ZfXMfRYnQxeVV0/img.png)

### 3. NAT 대역에 연결한 Internet-Gateway 생성

![](https://blog.kakaocdn.net/dn/x64PO/btsex2DpZUq/NrwdH4wA7o4QlH4vQN2CzK/img.png)

### 4. 라우팅 테이블 생성 및  생성한 테이블에  위에서 만든 인터넷 게이트웨이 생성

![](https://blog.kakaocdn.net/dn/yYlsj/btsetIrSLqx/degWzQ7RHXk7dBlQkSSNE0/img.png)

### 5. Nat로 사용할 서브넷 대역과 4.에서 만든 라우팅 테이블 연결

![](https://blog.kakaocdn.net/dn/KzE9W/btsexgn1BF5/g85KBWdkl7WlWsujWoWax0/img.png)

### 6. 인스턴스 생성 (Private 대역 / Nat 대역 각각 하나씩 ) > Nat 대역에는 Floating IP 할당

![](https://blog.kakaocdn.net/dn/cgTjGD/btsexdLE1m5/MrppKEERRcbPaaejWy1eRk/img.png)

### 7. Nat 인스턴스 접속 후 명령어 실행

```shell
#포워드 설정
sudo sysctl -w net.ipv4.ip_forward=1
#설정 등록확인 
sudo sysctl -p
#재부팅 시 설정 값이 사라지는 경우가 있어 재부팅 후 등록이 되도록 설정을 원하면 
root 권한으로 
vi /etc/sysctl.config 
 net.ipv4.ip_forward=1
 
 ---------------------
 # Nat 룰
 sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
 #재부팅 시 초기화를 방지 위해 
 sudo /sbin/iptables-save
```

### 8. 소스/대상 확인 변경

> Nat 인스턴스의 아이피를 확인 후 웹콘솔 > Network > Network Interface 에서 소스/대상 확인 해제

![](https://blog.kakaocdn.net/dn/tHmW4/btseyKWCcnj/WI9vJtGN7RFhLW03idw0Mk/img.png)

### 9. Private 인스턴스에 할당된 Routing 에  0.0.0.0/0 을  Nat  인스턴스로 전달하도록 룰 수정

![](https://blog.kakaocdn.net/dn/0W53A/btsey6dRWMu/lrnbiMmgMJ2qUs9m9n14RK/img.png)

### 확인

> Private 인스턴스는  Nat 인스턴스를 통해 접속가능

![](https://blog.kakaocdn.net/dn/kA3ym/btseyJXItZs/WQVbHBRZCE1hwxwpcR41ek/img.png)

같은 VPC 간의 통신은 가능하니 서브넷에 Internet gateway를 넣은 인스턴스(NAT 인스턴스) 하나를 두어 외부와 통신이 안 되는 Private 인스턴스들의 트래픽을 Nat 인스턴스로 보낸다.