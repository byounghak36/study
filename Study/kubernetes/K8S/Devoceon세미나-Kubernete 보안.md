---
title: Devoceon세미나-Kubernete 보안
tags: 
date: 2024_05_29
reference: 
link:
---

___
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

