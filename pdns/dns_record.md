# DNS 레코드란?
    
DNS Record는 DNS 서버가 수행할 작업을 문자열로써 작성해둔 일련의 텍스트 파일이며, 기록된 내용을 토대로 DNS 서버에 요청된 패킷을 처리한다.
https://ko.wikipedia.org/wiki/DNS_%EB%A0%88%EC%BD%94%EB%93%9C_%ED%83%80%EC%9E%85_%EB%AA%A9%EB%A1%9D

---
## 레코드별 설명
- A 레코드 
  
    A 레코드(A Record)는 쉽게 이야기하여, 사용자가 도메인 주소를 입력시 사용자를 어떤 서버에 연결할 것인지 제어하는 레코드다.

    |**도메인 이름**|**맵핑 된 주소**|
    |------------ |--------------|
    | tistory.com |121.53.105.234|
    
    참고로 A 도메인 매핑 설정에 따라서 일대다 / 다대일도 될 수 있다.

    ex)
    |**도메인 이름**|**맵핑 된 주소**|
    |:-----------:|:------------:|
    | tistory.com |121.53.105.234|
    ||121.22.10.202|
    ||121.6.15.211|
    
- CNAME 레코드
    
    CNAME 레코드는 도메인 별명 레코드라고 부르며, 하나의 도메인 주소를 다른 도메인주소로 매핑 시키는 레코드이다. 하나의 IP로 여러개의 서비스를 런칭할때 유용하다.
    IP주소를 직접 매핑할 수는 없으니 유의하여 사용하여야 한다. IP 주소가 자주 바뀌는 환경에 유용하다.
  
    | **서비스** |**도메인 주소**|**등록 주소** |**Type**|
    |:---------:|:----------:|:------------:|:-----:|
    |다음(Daum)  |daum.net    |203.133.167.81|A      |
    |다음2(Daum2)|daum2.net   |daum.net      |CMAKE  |

- AAAA 레코드
  
    AAAA 레코드는, A레코드의 IPv6 버젼이라고 보면 된다.

- MX 레코드

    MX 레코드는 특정 도메인에 대한 메일을 수신하는 메일 서버를 지정하는 레코드를 말한다.도메인 주소, 우선순위, 메일서버 등을 기입하며, 메일교환시 어떤 메일서버를 사용할지 작성한다. 우선순위는 숫자가 낮을수록 순위가 높고 모든 숫자가 같다면 외부 메일 서버에서는 랜덤으로 접속을 시도한다. 
    아래 명령어로 CMD에서 도메인의 MX레코드를 확인할 수 있다.
    ```
    kimbh@kimbh:~$ nslookup -type=mx naver.com
    Server:		127.0.0.53
    Address:	127.0.0.53#53

    Non-authoritative answer:
    naver.com	mail exchanger = 10 mx3.naver.com.
    naver.com	mail exchanger = 10 mx1.naver.com.
    naver.com	mail exchanger = 10 mx2.naver.com.

    Authoritative answers can be found from:
    ```
-  NS (Name Server)

    NS 레코드는 해당 도메인의 네임서버를 지정하는 레코드다. 호스팅 업체를 사용하지 않고 직접 네임서버를 운영한다면 필수적으로 등록되어야 한다.
    
    |**google.com**||
    |:-----------:|:------------:|
    |1차 네임서버|ns1.google.com|
    |2차 네임서버|ns2.google.com|
    |3차 네임서버|ns3.google.com|
    |4차 네임서버|ns4.google.com|

- PTR (Pointer)

    IP 주소에 대한 도메인 주소를 확인할 수 있는 레코드이다. A 레코드의 반대 방향인 레코드라 볼 수 있다. A레코드가 도메인네임에 대한 질의를 IP로 응답한다면, PTR레코드는 IP에 대한 질의를 도메인네임으로 응답한다.단, A레코드와 달리, PTR레코드는 1개의 IP에 1개의 도메인 네임만 가질 수 있다는 점이 다르다.

    |**아이피**     |**도메인**   |
    |--------------|-----------|
    |121.53.105.234|tistory.com|    

- SOA 레코드

    SOA레코드는 네임서버가 해당 도메인에 관하여 인증된 데이터를 가지고 있음을 증명하는 레코드이다.
    이 레코드는 기본 이름 서버, 도메인 관리자의 전자 메일, 도메인 일련 번호 및 영역 새로 고침과 관련된 여러 타이머를 포함하여 DNS 영역에 대한 핵심 정보를 지정한다.
    즉, SOA레코드가 없는 도메인은 네임서버에서 정상적으로 동작하지 않게 되는 것이다. SOA레코드는 도메인당 1개이다.

    naver의 경우 ns1.naver.com webmaster.naver.com 2021012809 21600 1800 1209600 180 이렇게 보여주고 있는데, 마스터 네임서버, 존 관리자 연락처, 존 데이터 동기화 시간, 갱신주기, 시도, 만료 등 정보를 나타내고 있는 것이다.

    - Mname / primary name : 도메인에 대한 기본 호스트네임
    - RName / mail addr : 관리자의 이메일 주소. 일반적인 이메일 형식인 @가 아니라 마침표가 들어있음.
    - serial : 도메인의 갱신 버전 번호. 일반적으로 날짜(YYYYMMDD)형식.
    - refresh : 도메인 영역의 데이터 갱신 여부를 체크하는 주기(초 단위)
    - retry : (장애 등의 이유로)refresh 주기로 체크하지 못했을 경우, 체크를 재시도하는 주기(초 단위)
    - expire : retry의 주기로 체크를 수차례 반복하다가, 도메인을 더이상 신뢰할 수 있는 영역이라고 간주하지 않아 서비스를 중단하는 최대 기한. 
    - minimum : 도메인을 찾을 수 없는 경우, 네임 서버가 도메인의 부재정보를 캐싱하는 시간

- TXT (TEXT) 레코드
    TXT 레코드는 텍스트를 입력할 수 있는 레코드이며, 주로 메모를 남기는 용도라고 보면 된다.
    실제로 네이버의 TXT 레코드를 살펴보면 다음과 같이 key:value 구조로 정보를 적어놓은걸 볼 수 있다
    ```
    kimbh@kimbh:~$ nslookup -type=txt naver.com
    Server:		127.0.0.53
    Address:	127.0.0.53#53

    Non-authoritative answer:
    naver.com	text = "google-site-verification=fK9dDFcEOeNM2Wr3xzNAN-XLcerfAGpOABdSYiqw4_s"
    naver.com	text = "facebook-domain-verification=0qyhf0qnkiuqfx4owhfuvwvsvjz8fk"
    naver.com	text = "v=spf1 ip4:111.91.135.0/27 ip4:125.209.208.0/20 ip4:125.209.224.0/19 ip4:210.89.163.112 ip4:210.89.173.104/29 ip4:117.52.140.128/26 ip4:114.111.35.0/24 ~all"

    Authoritative answers can be found from:
    ```
- CAA (Certificat Authority Authorization)
    
    도메인 인증기관에 관련된 레코드

---
## DNS 레코드 확인 ㅣ방법

- nslookup
    
    여러 운영체제를 지원하며, 도메인네임, IP주소, 기타 DNS 레코드를 알 수 있다.
        
    ```
    kimbh@kimbh:~$ nslookup google.com
    Server:		127.0.0.53
    Address:	127.0.0.53#53

    Non-authoritative answer:
    Name:	google.com
    Address: 142.250.204.46
    Name:	google.com
    Address: 2404:6800:4005:80c::200e
    ```
    만일 위에서 배운 각 레코드 타입에 대한 정보를 얻고 싶다면 -type 이나 -query 옵션을 주면 된다.
    ```
    kimbh@kimbh:~$ nslookup -type=mx google.com
    Server:		127.0.0.53
    Address:	127.0.0.53#53

    Non-authoritative answer:
    google.com	mail exchanger = 10 smtp.google.com.

    Authoritative answers can be found from:

    kimbh@kimbh:~$ nslookup -type=ns google.com
    Server:		127.0.0.53
    Address:	127.0.0.53#53

    Non-authoritative answer:
    google.com	nameserver = ns3.google.com.
    google.com	nameserver = ns4.google.com.
    google.com	nameserver = ns1.google.com.
    google.com	nameserver = ns2.google.com.

    Authoritative answers can be found from:

    kimbh@kimbh:~$ nslookup -type=a google.com
    Server:		127.0.0.53
    Address:	127.0.0.53#53

    Non-authoritative answer:
    Name:	google.com
    Address: 142.250.204.46
    ```
- 한국 kisa의 후이즈 사이트

    https://whois.kisa.or.kr