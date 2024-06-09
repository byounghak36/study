---
title: ssl_communication_process
tags:
  - openssl
  - ssl
date: 2024_05_30
Modify_Date: 
reference: 
link:
---

# SSL 통신 과정
결론부터 말하면 SSL은 암호화된 데이터를 전송하기 위해서 공개키와 대칭키를 혼합해서 사용한다. 즉 클라이언트와 서버가 주고 받는 실제 정보는 대칭키 방식으로 암호화하고, 대칭키 방식으로 암호화된 실제 정보를 복호화할 때사용할 대칭키는 공개키 방식으로 암호화해서 클라이언트와 서버가 주고 받는다. 이 설명만으로는 이해하기 어려울 것이다. 아래의 관계만 일단 머리속에 기억해두고 좀 더 구체적인 설명으로 넘어가자.

실제 데이터 : 대칭키
대칭키의 키 : 공개키
컴퓨터와 컴퓨터가 네트워크를 이용해서 통신을 할 때는 내부적으로 3가지 단계가 있다. 아래와 같다.

**악수 -> 전송 -> 세션종료**

이것은 은밀하게 일어나기 때문에 사용자에게 노출되지 않는다. 이 과정에서 SSL가 어떻게 데이터를 암호화해서 전달하는지 살펴보자.

---

## 1. 악수 (handshake)
사람과 사람이 소통을 할 때를 생각해보자. 우선 인사를 한다. 인사를 통해서 상대의 기분과 상황을 상호탐색을 하는 것이다. 이 과정이 잘되야 소통이 원활해진다. 클라이언트와 서버 사이도 마찬가지다. 실제 데이터를 주고 받기 전에 클라이언트와 서버는 일종의 인사인 Handshake(진짜로 사용하는 기술용어다)를 한다. 이 과정을 통해서 서로 상대방이 존재하는지, 또 상대방과 데이터를 주고 받기 위해서는 어떤 방법을 사용해야하는지를 파악한다.

SSL 방식을 이용해서 통신을 하는 브라우저와 서버 역시 핸드쉐이크를 하는데, 이 때 SSL 인증서를 주고 받는다. 이 과정은 앞에서 설명한 바 있다. 인증서에 포함된 서버 측 공개키의 역할은 무엇일까를 이제 알아보자.

공개키는 이상적인 통신 방법이다. 암호화와 복호화를 할 때 사용하는 키가 서로 다르기 때문에 메시지를 전송하는 쪽이 공개키로 데이터를 암호화하고, 수신 받는 쪽이 비공개키로 데이터를 복호화하면 되기 때문이다. 그런데 SSL에서는 이 방식을 사용하지 않는다. 왜냐하면 공개키 방식의 암호화는 매우 많은 컴퓨터 자원을 사용하기 때문이다. 반면에 암호화와 복호화에 사용되는 키가 동일한 대칭키 방식은 적은 컴퓨터 자원으로 암호화를 수행할 수 있기 때문에 효율적이지만 수신측과 송신측이 동일한 키를 공유해야 하기 때문에 보안의 문제가 발생한다. 그래서 SSL은 공개키와 대칭키의 장점을 혼합한 방법을 사용한다. 그 핸드쉐이크 단계에서 클라이언트와 서버가 통신하는 과정을 순서대로 살펴보자.

1. 클라이언트가 서버에 접속한다. 이 단계를 Client Hello라고 한다. 이 단계에서 주고 받는 정보는 아래와 같다.

	- 클라이언트 측에서 생성한 랜덤 데이터 : 아래 3번 과정 참조
	- 클라이언트가 지원하는 암호화 방식들 : 클라이언트와 서버가 지원하는 암호화 방식이 서로 다를 수 있기 때문에 상호간에 어떤 암호화 방식을 사용할 것인지에 대한 협상을 해야 한다. 이 협상을 위해서 클라이언트 측에서는 자신이 사용할 수 있는 암호화 방식을 전송한다.
	- 세션 아이디 : 이미 SSL 핸드쉐이킹을 했다면 비용과 시간을 절약하기 위해서 기존의 세션을 재활용하게 되는데 이 때 사용할 연결에 대한 식별자를 서버 측으로 전송한다.
 
2. 서버는 Client Hello에 대한 응답으로 Server Hello를 하게 된다. 이 단계에서 주고 받는 정보는 아래와 같다.

	- 서버 측에서 생성한 랜덤 데이터 : 아래 3번 과정 참조
	- 서버가 선택한 클라이언트의 암호화 방식 : 클라이언트가 전달한 암호화 방식 중에서 서버 쪽에서도 사용할 수 있는 암호화 방식을 선택해서 클라이언트로 전달한다. 이로써 암호화 방식에 대한 협상이 종료되고 서버와 클라이언트는 이 암호화 방식을 이용해서 정보를 교환하게 된다.
	- 인증서
 
3. 클라이언트는 서버의 인증서가 CA에 의해서 발급된 것인지를 확인하기 위해서 클라이언트에 내장된 CA 리스트를 확인한다. CA 리스트에 인증서가 없다면 사용자에게 경고 메시지를 출력한다. 인증서가 CA에 의해서 발급된 것인지를 확인하기 위해서 클라이언트에 내장된 CA의 공개키를 이용해서 인증서를 복호화한다. 복호화에 성공했다면 인증서는 CA의 개인키로 암호화된 문서임이 암시적으로 보증된 것이다. 인증서를 전송한 서버를 믿을 수 있게 된 것이다.

	클라이언트는 상기 2번을 통해서 받은 서버의 랜덤 데이터와 클라이언트가 생성한 랜덤 데이터를 조합해서 pre master secret라는 키를 생성한다. 이 키는 뒤에서 살펴볼 세션 단계에서 데이터를 주고 받을 때 암호화하기 위해서 사용될 것이다. 이 때 사용할 암호화 기법은 대칭키이기 때문에 pre master secret 값은 제 3자에게 절대로 노출되어서는 안된다.

	그럼 문제는 이 pre master secret 값을 어떻게 서버에게 전달할 것인가이다. 이 때 사용하는 방법이 바로 공개키 방식이다. 서버의 공개키로 pre master secret 값을 암호화해서 서버로 전송하면 서버는 자신의 비공개키로 안전하게 복호화 할 수 있다. 그럼 서버의 공개키는 어떻게 구할 수 있을까? 서버로부터 받은 인증서 안에 들어있다. 이 서버의 공개키를 이용해서 pre master secret 값을 암호화한 후에 서버로 전송하면 안전하게 전송할 수 있다.
 
4. 서버는 클라이언트가 전송한 pre master secret 값을 자신의 비공개키로 복호화한다. 이로서 서버와 클라이언트가 모두 pre master secret 값을 공유하게 되었다. 그리고 서버와 클라이언트는 모두 일련의 과정을 거쳐서 pre master secret 값을 master secret 값으로 만든다. master secret는 session key를 생성하는데 이 session key 값을 이용해서 서버와 클라이언트는 데이터를 대칭키 방식으로 암호화 한 후에 주고 받는다. 이렇게해서 세션키를 클라이언트와 서버가 모두 공유하게 되었다는 점을 기억하자.
 
5. 클라이언트와 서버는 핸드쉐이크 단계의 종료를 서로에게 알린다.

## 2. 세션
세션은 실제로 서버와 클라이언트가 데이터를 주고 받는 단계이다. 이 단계에서 핵심은 정보를 상대방에게 전송하기 전에 session key 값을 이용해서 대칭키 방식으로 암호화 한다는 점이다. 암호화된 정보는 상대방에게 전송될 것이고, 상대방도 세션키 값을 알고 있기 때문에 암호를 복호화 할 수 있다.

그냥 공개키를 사용하면 될 것을 대칭키와 공개키를 조합해서 사용하는 이유는 무엇을까? 그것은 공개키 방식이 많은 컴퓨터 파워를 사용하기 때문이다. 만약 공개키를 그대로 사용하면 많은 접속이 몰리는 서버는 매우 큰 비용을 지불해야 할 것이다. 반대로 대칭키는 암호를 푸는 열쇠인 대칭키를 상대에게 전송해야 하는데, 암호화가 되지 않은 인터넷을 통해서 키를 전송하는 것은 위험하기 때문이다. 그래서 속도는 느리지만 데이터를 안전하게 주고 받을 수 있는 공개키 방식으로 대칭키를 암호화하고, 실제 데이터를 주고 받을 때는 대칭키를 이용해서 데이터를 주고 받는 것이다.

## 3. 세션종료
데이터의 전송이 끝나면 SSL 통신이 끝났음을 서로에게 알려준다. 이 때 통신에서 사용한 대칭키인 세션키를 폐기한다.