---
title: Devoceon세미나-Kubernete 보안
tags: 
date: 2024_05_29
reference: 
link:
---



목차
- [[#OpenInfra 커뮤니티|OpenInfra 커뮤니티]]
- [[#Kubernetes Korea Group|Kubernetes Korea Group]]
- [[#그카나마알아? K Ca Na Mg Al Zn|그카나마알아? K Ca Na Mg Al Zn]]
- [[#K8S Secrity = REST API Security|K8S Secrity = REST API Security]]
	- [[#K8S Secrity = REST API Security#API Internal : AuthN, AuthZ & Admission|API Internal : AuthN, AuthZ & Admission]]
	- [[#K8S Secrity = REST API Security#Authntication|Authntication]]
	- [[#K8S Secrity = REST API Security#Authentication : X.509|Authentication : X.509]]
	- [[#K8S Secrity = REST API Security#Authentication : ID Token|Authentication : ID Token]]
		- [[#Authentication : ID Token#Authentication|Authentication]]
	- [[#K8S Secrity = REST API Security#Authentication : RBAC|Authentication : RBAC]]
	- [[#K8S Secrity = REST API Security#Admission : Polisy enforcement for governance|Admission : Polisy enforcement for governance]]
		- [[#Admission : Polisy enforcement for governance#주요 Admission Controllers|주요 Admission Controllers]]
		- [[#Admission : Polisy enforcement for governance#Admission Controller의 동작 과정|Admission Controller의 동작 과정]]
- [[#Native Kubernetes 접근 제어 방식|Native Kubernetes 접근 제어 방식]]
- [[#OIDC를 활용한 Kubernetes 접근 제어 방식|OIDC를 활용한 Kubernetes 접근 제어 방식]]
- [[#TKS의 Kubernetes 접근 제어 방식|TKS의 Kubernetes 접근 제어 방식]]
	- [[#TKS의 Kubernetes 접근 제어 방식#개선 사항|개선 사항]]
- [[#기술 구성|기술 구성]]
	- [[#기술 구성#인증|인증]]
		- [[#인증#Json Web Token (JWT)|Json Web Token (JWT)]]
		- [[#인증#OpenID Connect|OpenID Connect]]
	- [[#기술 구성#인가(Authorization)|인가(Authorization)]]
	- [[#기술 구성#Token 기반 인증/인가 동작 흐름|Token 기반 인증/인가 동작 흐름]]
		- [[#Token 기반 인증/인가 동작 흐름#Kunbernetes 의 RBAC 설정|Kunbernetes 의 RBAC 설정]]
	- [[#기술 구성#이를 위한 작업들...|이를 위한 작업들...]]

---

# SKT Telecom CTO - 양승현
---
OpenInfra 커뮤니티 그룹 콜라보
오프닝
# 커뮤니티 소개 (쿠버네티스 커뮤니티 안승규, 오픈인프라 커뮤니티 조성수)
---
## OpenInfra 커뮤니티
- OpenInfra foundation 의 공식 유저 그룹 (페이스북, 유투브, 디스코드)
- 정기 밋업 (온라인/오프라인)
- 오픈 인프라 기술 스터디
- OpenInfra 서밋
## Kubernetes Korea Group
- CNCF Graduated Project
> [CNCF란?](https://kim-dragon.tistory.com/100#CNCF%EB%-E%--%-F)
> CNCF(Cloud Native Computing Foundation)는 2015년 12월 리눅스 재단 소속의 비영리 단체입니다. 첫 번째 프로젝트로 Kubernetes 를 Google에서 기증하였습니다. 클라우드네이티브 컴퓨팅 환경에서 필요한 다양한 오픈소스 프로젝트를 추진하고 관리하고 있습니다. CNCF맴버로는 인텔, Arm, 알리바바클라우드, 에저, 구글, 레드헷, SAP, vmware 등등 500개 이상의 글로벌 기업들이 활동하고 있습니다.
![[Pasted image 20240529140855.png]]
- Open Plicy Agent(OPA), Prometheus, CRI-O 등이 속해있음. 가장 먼저 가입된 프로젝트는 Kubernetes
- Kubernetes CON 을 진행할때마다 매년 방문자가 늘어남, 점점 Kubernetes 가 확대되고있다고 판단됨.

# Kubernetes Security - 그카나마알아 (한규호)
---
커뮤니티의 효용성이 높다고 생각함, 다같이 뭉쳐서 서로 도움을 주는 모습을 지향함. 세미나는 세미나를 통해서 정보에대한 가치를 느끼고 서로간의 피드백을 얻기 위함.
## 그카나마알아? K Ca Na Mg Al Zn 
보안의 정보는 흩어져있는 경향이 있음, 따라서 모든것을 알기는 힘들지만 쿠버네티스는 우연인지 몰라도 단순한편이다. 따라서 다순 암기로도 높은 보안성을 얻을 수 있음.

## K8S Secrity = REST API Security
REST API 란 내가 원하는 바를 데이터로 다른곳에 저장하고, API 를 호출하여 업데이트및 삭제 등을 진행함.
K8S도 동일하게 REST API 형태로 구성되어 이씅며, API 서버로 모든 작업을 시행함.
K8S의 경우 API를 통하여 다른 컴포넌트를 제어함으로 API서버를 보안에 적합하게 만들면된다.

### API Internal : AuthN, AuthZ & Admission
![[Pasted image 20240529141156.png]]
Admision 이란? (Write/Delete)
- 만든사람 이름 조직등을 annotation 에 강제로 작성하도록 할 수 있음
- 금칙어 설정
- 컨테이너 설정 등을 제한함

정리 : K8S 보안은 REST APi 보안이며 인증과 인가가 있으며, Admission을 활용하여 좀더 강력하게 제어할 수 있다.

### Authntication
![[Pasted image 20240529141408.png]]

쿠버네티스의 신원증명수단으로 보통 X.509 or ID Token 등을 활용함
쿠버네티스는 RestAPI 를 활용함으로 대중적으로 많이 사용하는 인증방식을 사용함.

> [!NOTE] X.509, ID Token 란
> 

### Authentication : X.509
![[Pasted image 20240529142031.png]]
X.509는 암호학에서 공개키 인증서와 인증알고리즘의 표준 가운데에서 공개 키 기반(PKI)의 ITU-T 표준이다.
https://ko.wikipedia.org/wiki/X.509

### Authentication : ID Token
![[Pasted image 20240529142039.png]]

#### Authentication

인증대상이
고정된 경우 : X.509 ex) Kube-scheduler
- System to System

다이나믹한 경우 : ID Token ex) User, Pod
- User
Kubernetes 설치시 인증서 배포 방식을 선택하는것이 중요함.

### Authentication : RBAC
![[Pasted image 20240529142340.png]]
rules 를 통하여 신원별 자원에 대한 권한 부여
Subjects는 annotation에 작성하지만 따로 관리하는 것은 없음
쿠버네티스 자체로 컨트롤 하기에 RBAC 이 가장 쉬운편이다.

### Admission : Polisy enforcement for governance
  
Kubernetes Admission Controllers는 Kubernetes API 서버에 요청이 들어올 때 이 요청을 가로채서 검사하고 수정할 수 있는 플러그인입니다. 이들은 클러스터에 리소스가 생성, 업데이트, 삭제, 연결되는 과정을 제어하며, 클러스터의 보안과 정책 준수를 돕습니다. Admission Controllers는 크게 두 가지 종류로 나눌 수 있습니다:

1. **Validating Admission Controllers**:
    - 이들은 API 서버로 들어오는 요청을 검증합니다. 요청이 클러스터의 정책에 맞는지 확인하고, 요청이 유효하지 않다고 판단되면 요청을 거부합니다. 예를 들어, 특정 네임스페이스에만 애플리케이션을 배포할 수 있도록 하는 정책을 구현할 수 있습니다.
2. **Mutating Admission Controllers**:
    - 이들은 API 서버로 들어오는 요청을 수정할 수 있습니다. 예를 들어, 리소스에 기본 값을 설정하거나, 요청이 허용되기 전에 추가적인 라벨을 붙일 수 있습니다.

#### 주요 Admission Controllers
1. **NamespaceLifecycle**: 네임스페이스의 생명주기를 관리하고, 삭제된 네임스페이스에 리소스를 생성하는 것을 방지합니다.
2. **LimitRanger**: 네임스페이스에 할당된 리소스 제한을 적용합니다.
3. **ResourceQuota**: 네임스페이스별로 리소스 쿼터를 설정하여 클러스터 리소스의 과도한 사용을 방지합니다.
4. **PodSecurityPolicy**: 파드가 생성되기 전에 보안 정책을 적용합니다.
5. **DefaultStorageClass**: 파드가 스토리지 클래스를 지정하지 않았을 때 기본 스토리지 클래스를 할당합니다.
6. **DenyEscalatingExec**: 높은 권한을 가진 파드에 대한 `exec` 및 `attach` 요청을 거부합니다.

#### Admission Controller의 동작 과정
1. **요청 수신**: 클라이언트가 Kubernetes API 서버에 요청을 보냅니다.
2. **예비 검증**: 요청이 형식적으로 유효한지 기본 검증이 이루어집니다.
3. **Mutating Admission Controllers**: 요청을 수정할 수 있는 Admission Controllers가 순차적으로 요청을 처리합니다.
4. **Validating Admission Controllers**: 요청이 정책에 맞는지 검증하는 Admission Controllers가 순차적으로 요청을 처리합니다.
5. **최종 처리**: 요청이 모든 Admission Controllers를 통과하면 클러스터에 적용됩니다.

Admission Controllers는 클러스터 관리자가 정책을 적용하고 보안을 강화하는 중요한 도구입니다. 사용자는 이를 통해 클러스터의 상태를 더 세밀하게 제어하고 관리할 수 있습니다.

금 세미나 에서는 Admission 을 통해서 제한된 규칙내에서 동작하도록 설계하고, 보안규칙내에서 벗어나면 쿠버네티스 시스템상에서 사용자에게 알리는 프로세스를 구축하는것을 목표로함. 금액적 측면, 퀄리티적 측면, 보안적 측면에서 만족하도록 admission 을 통하여 강제하도록 한다.

그런 이유로 DevOceon 커뮤니티를 통하여 K8S 보안 1~4 탄을 업로드하였으니 확인하길 바란다.
![[Pasted image 20240529143147.png]]
컨테이너는 VM 보다 보안이 안좋아? 이런 주제에 대해서 논의하길 바람
MicroService 를 만든다는것은 빠르고 효율적으로 시스템을 개발하기 위함임.

# OIDC를 이용해 동적으로 Kubernetes 접근 제어하기 (SK Telecom 개발팀 조동규)
---
## Native Kubernetes 접근 제어 방식
Shared Kubernets Clusters를 사용하다보면, 인프라 운영자가 kubernetes 클러스터를 관리하고 여러 동작을 하는 서비스와 개발자 및 운영자가 클러스터를 활용한다.
현재는 아래와같이 접근을 제어하고 있다.
![[Pasted image 20240529143815.png]]

역할당 Service Accont 를 만들고 Token을 만들고 해당 파일을 kubeconfig 로 만들어 클러스터를 접속하여 활용한다.
kube config 란 config 파일로 cluster URL 등이 들어가고 user 및 token을 기입하여 사용자와 사용자의 역할을 증명하는데 사용한다.
해당 정보들을 엑셀화 해서 관리하곤한다.

문제점
- 너무 가독성이 안좋다.
- 과거 내용을 다시 찾기 힘들다
- 고정된 토큰을 다시 회수하는것이 거의 불가능하다. 새로운 사용자는 과거 토큰을 삭제하고 새로이 발급하여 사용하는데 클러스터 관리자 입장에서는 신뢰성이 없다.

## OIDC를 활용한 Kubernetes 접근 제어 방식
![[Pasted image 20240529144308.png]]
따라서 중앙 인증서버를 두어서 사용자가 인증서버로부터 역할을 받아 활용하여 자동화한다.
관리자는 클러스터마다 작업이 필요없고 중앙 인증서버만 관리한다.

Service Account별 config 파일을 발급받아 사용한다.
아래는 작동방식이다.

## TKS의 Kubernetes 접근 제어 방식
![[Pasted image 20240529144749.png]]
TKS UI 를 통하여 모든것을 자동화 할 수 있다.

### 개선 사항
![[Pasted image 20240529144849.png]]

![[Pasted image 20240529144932.png]]

## 기술 구성
### 인증
- 사용자가 서버에게 자신이 누구인지를 증명하는 과정
- 주요 step
	- 자격 증명 : 사용자는 자신의 신원을 증명하기 위해 자격 증명을 제출
	- 신원 검증 : 제출된 자격증명 정보를 기존에 등록된 계정 정보와 비교하여 사용자의 신원을 확인
	- 결과 전송 : 검증이 성공하면 사용자는 인증된 것으로 간주되어 시스템에 접근할 수 있는 인증 토큰 발급
	- 인증 토큰 전송 : 제출된 인증 토큰 유효성 검증 & 신원 화인
- 개인화된 서비스 제공 & 자원 보호
#### Json Web Token (JWT)
![[Pasted image 20240529145307.png]]
#### OpenID Connect
신원 확인부분을 ID Token에서 구현되어 있다.
![[Pasted image 20240529145815.png]]
### 인가(Authorization)
![[Pasted image 20240529150112.png]]
특정 사용자가 특정 자원에서 어떤 행위를 할 수 있는지가 Permission
행위의 주체는 Token에서 찾는다.
이런 룰에대한 관리 방식이 필요로한다.
주체를 역할로 그룹화 하여 주체를 한그룹 한그룹으로 그룹화 한것이 RBAC 이다.

### Token 기반 인증/인가 동작 흐름
![[Pasted image 20240529150240.png]]

#### Kunbernetes 의 RBAC 설정
![[Pasted image 20240529150145.png]]

### 이를 위한 작업들...
![[Pasted image 20240529150355.png]]
위의 작업을 크러스터 관리자가 모두 해야한다는 부담이 느껴진다. 그래서 이런부분을 자동화 할 수 있다면 자동화 해야한다 판단되어
초기설정은 Oauth 서버에서 자동으로 구성되고
Kubernetes 관리는 TKS Backend 자동화를 통하여 TKS Console 을 통하여 작업한다.

# Kubnernetes 에게 Policy 란?
---
## Kubnernetes 정책 관리
![[Pasted image 20240529153329.png]]

## Kubnernetes 정책관련 지원 기능
![[Pasted image 20240529153419.png]]

## Kubnernetes Admission Controller
![[Pasted image 20240529153537.png]]

## Kubnernetes 용 정책관리 도구
![[Pasted image 20240529153702.png]]

## 정책관리별 장단점 비교
![[Pasted image 20240529153725.png]]

## OPA (Open Policy Agent)
![[Pasted image 20240529154226.png]]
![[Pasted image 20240529154326.png]]

Rego 언어를 활용하여 정책을 코드로 구현하는 특징이 있음
## Gatekeeper
![[Pasted image 20240529154512.png]]
![[Pasted image 20240529154734.png]]

## TKS
![[Pasted image 20240529155036.png]]

![[Pasted image 20240529155303.png]]
![[Pasted image 20240529155447.png]]

![[Pasted image 20240529155634.png]]

![[Pasted image 20240529155801.png]]

![[Pasted image 20240529155934.png]]

# 쿠버네티스 워크로드 보안? 어떻게 동작하는거니? - 네트워크 시스템 보안 연구실 남재현
---
![[Pasted image 20240529162119.png]]
![[Pasted image 20240529162224.png]]

## 쿠버네티스 워크로드 보안
![[Pasted image 20240529162419.png]]
![[Pasted image 20240529162505.png]]

마이크로 서비스를 구성하기전 사전단계에서 구성하는 서비스다.

우리가 집중해야 하는것은 실시간으로 바뀌는것이다.

### 단계별 보안
![[Pasted image 20240529162629.png]]

Service 를 deploy 했을때 안전한가?
- 라이브 변경사항
- 고객 request
- 기존에 사용하던 어플리케이션의 취약점이 사라지지 않는다.
- 컨테이너로 공격자가 들어와서 보안을 취약하게 할 수 있음
- 런타임에서 사실은 중요한 솔루션이 필요하다.

### 실시간으로 바뀌는 것?
![[Pasted image 20240529162837.png]]

- 워크로드를 변경시 다양한 부분이 함께 변동된다.
- 실제로 보안을 하고자하는 부분, 쿠버네티스에 Deploy 를 했을때 runtime security 를 구현해야한다.

### 시스템 레벨에서의 워크로드 보안
![[Pasted image 20240529163025.png]]

- 다양한 워크로드보안 솔루션이 존재함
![[Pasted image 20240529163109.png]]

- 악성행위란 보안정책에 위배된 액션을 이야기한다.
- 두가지 클래스로 볼 수 있다.
- alerting 및 blocking이 필요하다.

### eBPF : extended Berkeley Packet Filter
![[Pasted image 20240529163225.png]]

### 시스템레벨 에서의 보안 정책
![[Pasted image 20240529163307.png]]

- 어떤 call 이 나올때, request 가 왔을때의 보안

![[Pasted image 20240529163348.png]]

- 어떤 패턴의 액션이 생겼을때 blocking 한다.
- but 너무 로우레벨에서 세팅한다. 어렵다.

![[Pasted image 20240529163440.png]]

- 보안을 위해서 프로세스 죽이기 등의 액션을 처리한다.
- 뭔가를 죽인다는것 자체는 서비스의 중단을 야기하기에 좋은 보안 솔루션이 아니다.
- Kubernetes가 자체적으로 복구하더라도 다운 타임이 발생한다.
- 강제적으로 주어진 환경에대해서 복구시스템을 잘 만들어 두었느냐?
- 싱크가 깨지거나 외의 이슈가 발생할 수 있다.
- 공격자 입장에서 이런 솔루션이 들어가있다면 게속 공격을 던지면서 서비스의 중단을 유도할것이다.

### 상용제품은 오픈소스SW보다 좋을까?
![[Pasted image 20240529163638.png]]

- 사용 SW 도 프로세스를 죽인다.
- 어떤 공격이 발생했을대 알럿을하고 액션을 취한다.
- 대안은? inlin mitigation 이다.
### kubearmor
![[Pasted image 20240529163811.png]]
- kubearmor 는 프로세스를 죽이지 않고 denied 를 시킨다.
- 특정 액션만 block 시킬 수 있다.

![[Pasted image 20240529163955.png]]

## Inline Mitiation? 어떻게?
### Inline Mitiation
![[Pasted image 20240529164038.png]]
- 모니터링을 진행하고
![[Pasted image 20240529164107.png]]
- system call 만 이요하면 프로세스를 시작했을때 프로세스 이름만 나옴
- lsm hook 은 구체적인 프로세스 세부사항을 알 수 있음
- 이를 적절히 섞어서 사용하면 좋음

![[Pasted image 20240529164308.png]]

- 시스템 레벨에서 네임스페이스 정보를 함께 뽑는다.
- container 정보
- pod 정보 를 매칭하여 구체적인 액션정보를 탐지한다.
![[Pasted image 20240529164401.png]]
- LSM 훅에 각 내용을 담고 kubearmor 나 등등에 매칭이되면 permission denied 시킨다.
- 액션에 관해서만 permission denied 시킨다.

## 네트워크 레벨에서의 워크로드 보안
![[Pasted image 20240529164512.png]]
![[Pasted image 20240529164545.png]]
![[Pasted image 20240529164629.png]]
- 마지막에 개발 : 아! 우리 서비스 업데이트 했어!
- 이걸 어떻게 해야할까? 고민이 많다.
![[Pasted image 20240529164736.png]]
- 해결을 위해
- policy 자동 생성등을 많이 사용하지만
- 동적으로 policy를 적용할 수 있지만 완벽하지는 않다.

## 네트워크 레벨에서의 워크로드 보안
![[Pasted image 20240529164835.png]]
- iptables 는 검증이 안된다.
- 유지보수가 많이 어렵다.

![[Pasted image 20240529164907.png]]
- eBPF 기반도 많이 사용한다.
- 가상 인터페이스가 조냊하고 eBPF 를 하나씩 붙인다.
- 그리고 보안 Map을 업데이트한다.

![[Pasted image 20240529165025.png]]
![[Pasted image 20240529165039.png]]

![[Pasted image 20240529165106.png]]
- eBPF 를 인터페이스에 붙이면 blf_redirect 가 가능하다.
- index 값을 넣어주면 패킷을 거기에 푸쉬한다.

## 마지막으로 API !!!
![[Pasted image 20240529165312.png]]
- 그냥 혼돈이다...
- network 레벨이면 ip다 결국엔
- 하지만 api 로 가면 너무 구체적이다.
- api 보안쪽으로 들어가면 당연히 자연스럽게 rest api 등을 사용할텐데,
- 누가 누구랑 통신할대 어떤 api를 쓰는지 그 컨텐츠가 뭔지 확이해야한다.

![[Pasted image 20240529165459.png]]
- 당연히 이런 서비스들을 활용할거다.
- 당연히 모든 api 통신을 로깅한다.
- 잘못된것은 차단하면 된다.

![[Pasted image 20240529165536.png]]
- 하지만 이부분을 차단하다보면 와일드카드가 하나씩껴서 디파인하기 쉽지않다.
- 그래서 policy를 쓸대는 \* 을 많이 붙이는데
![[Pasted image 20240529165626.png]]
- 정규 표션식을 쓰면 너무 복잡해진다.
![[Pasted image 20240529165652.png]]
- 이하 본문 내용
- 결국은 user level 로 가야하고

![[Pasted image 20240529165747.png]]
- 결국 이런 user-space의 구성이 생긴다.
![[Pasted image 20240529165914.png]]
- 실제로 워크로드 보안정책은 쉽지는 않다.
- 보안 정책을 만들기 너무 어려움
- 이것은 개발팀도 잘 모른다.
- 어플리케이션을 어떻게 동작하는지 정의하라! 이러면 정의하기가 힘듬
- 결론 : 어렵다


---
# 질의 응담
키클락과 oidc 와 비교하면?
- 키클락도 많이 쓴다, 둘다 쓰니까 둘다 공부해라 근데 키클락은 좀 어렵기하다. TKS 는 둘다 좀 쉽게 설정하도록 만들었으니 잘 써봐라...
- 