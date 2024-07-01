---
title: tcpdump_사용법
tags:
  - linux
date: 2024_07_01
reference:
  - https://study-melody.tistory.com/36
link:
---
### tcpdump란 무엇인가?

리눅스/유닉스 계열 OS에서 조건식에 만족하는 네트워크를 통해 송수신 되는 패킷 정보를 표시해주는 프로그램입니다. 

### tcpdump 사용 방법과 다양한 옵션 등

프롬프트에서 tcpdump 명령을 입력해서 사용합니다. 다양한 옵션이 존재하고 조건부 부분에 표현 방식과 범위를 정해 다양한 형식으로 표현할 수 있습니다.

### tcpdump 옵션

|   |   |
|---|---|
|-c 숫자|지정한 수 만큼 출력|
|-i 네트워크 인터페이스|지정한 네트워크 인터페이스를 경유하는 패킷을 출력|
|-w file|출력한 패킷 정보를 파일로 만든다|
|-r file|w 옵션으로 만든 파일을 읽는다|
|-v|패킷 내용을 상세히 본다|

|     |     |     |
| --- | --- | --- |
| 그리고 | and | &&  |
| 또는  | or  | \|  |
| 아니다 | not | !   |

|   |   |
|---|---|
|네트워크|network, mask|
|출발지|src|
|목적지|dst|
|포트|port|
|도메인|host|

### tcpdump 사용 예시
- **tcpdump -i eth0** : 네트워크 인터페이스 eth0를 지나는 패킷 덤프
- **tcpdump -i eth0 -c 5** :  네트워크 인터페이스 eth0를 지나는 패킷 덤프 5개
- **tcpdump -i eth0 tcp port 80** : TCP 80 포트로 통신하는 패킷 덤프
- **tcpdump -i eth0 src 192.168.1.18** : 출발지 IP가 192.168.1.18인 패킷 덤프
- **tcpdump -i eth0 dst 192.168.1.19** : 목적지 IP가 192.168.1.19인 패킷 덤프
- **tcpdump -i eth0 src 192.168.1.19 and tcp port 80** : 목적지 IP가 192.168.1.19이고 TCP 80 포트인 패킷 덤프
- **tcpdump -i eth0 dst 192.168.1.19** : 목적지IP가 192.168.1.19인 패킷 덤프
- **tcpdump host 192.168.1.18 : 특정 호스트 IP(192.168.1.18)로 양방향 패킷 덤프
- **tcpdump src 192.168.1.18* : 특정 호스트 중에서 출발지가 192.168.1.18인 패킷 덤프
- **tcpdump dst 192.168.1.18 : 특정 호스트 중에서 목적지가 192.168.1.18인 패킷 덤프
- **tcpdump -w dump.log** : 결과를 파일로 저장
- **tcpdump -r dump.log** : 저장한 파일을 읽음
- **tcpdump port 22** : 포트가 양뱡항으로 22인 패킷 덤프
- **tcpdump src port 22** : 출발지 포트가 22인 패킷 덤프
- **tcpdump dst port 22** : 목적지 포트가 22인 패킷 덤프
- t**cpdump udp and src port 123** : UDP이고 출발지 포트가 123인 패킷 덤프
- **tcpdump src **192.168.1.18** and not dst port 22** : 출발지 IP가 192.168.1.18이고 목적지 포트가 22가 아닌 패킷 덤프
