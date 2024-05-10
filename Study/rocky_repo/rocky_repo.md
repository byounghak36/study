---
title: rocky_repo
tags:
  - linux
date: 
Modify_Date: 
reference: 
link:
---

# Rocky9 local Yum Repository 생성
## Yum 구성
**메타데이터(Metadata)** : 패키지에 대한 정보를 포함하는 데이터를 메타데이터라고 칭함. 이 메타데이터에는 패키지 이름, 버전, 종속성, 설치 및 업데이트에 필요한 정보 등이 포함됨. 이 메타데이터는 주로 XML 또는 SQLite 형식으로 제공

**패키지(Packages)** : YUM repository에는 실제 소프트웨어 패키지가 포함됨, 이 패키지들은 메타데이터에서 참조되며, 사용자가 YUM을 사용하여 설치, 업데이트 또는 삭제할 수 있음. 패키지는 일반적으로 RPM(Red Hat Package Manager) 형식으로 제공됨

**repodata 디렉터리** : 이 디렉터리에는 repository 메타데이터가 저장됨. 이는 주로 repomd.xml 또는 other.xml과 같은 파일이며, 이 파일들은 repository의 메타데이터를 가리키고 패키지 정보를 검색할 수 있도록 함

**GPG 키** : 패키지가 무결하고 신뢰할 수 있는 소스에서 온 것임을 보장함. 따라서 GPG 키를 사용함으로써 악성 패키지나 변경된 패키지가 시스템에 설치되는 것을 방지할 수 있음.

---

## Repo 생성 방법
### 사용 명렁어
`dnf reposync`, `createrepo`

#### 1. repo sync 진행
```bash
dnf reposync --gpgcheck --delete --repoid=basos --download-path=<dir> --downloadcomps --newest-only --download-metadata
```
##### 옵션 설명
dnf reposync: dnf의 reposync 도구를 실행하여 RPM 저장소를 동기화함

`--gpgcheck`: 다운로드한 패키지의 GPG 체크를 수행함. 이 옵션을 사용하면 저장소에서 다운로드한 패키지가 유효한 GPG 서명을 가진 것인지 확인할 수 있음.

`--delete`: 이 옵션을 사용하면 로컬 시스템에서 이전에 다운로드한 패키지를 삭제함. 따라서 저장소에서 제거된 패키지가 로컬 시스템에서도 제거됨.

`--repoid=basos`: 동기화할 저장소의 ID를 지정함. 이 예시에서는 "basos"라는 저장소를 지정함.

`--download-path=<dir>`: 다운로드한 패키지를 저장할 디렉토리를 지정함. \<dir> 부분에는 원하는 디렉토리 경로를 입력함.

`--downloadcomps`: 저장소의 comps.xml 파일을 다운로드함. comps.xml 파일은 그룹 정보를 포함하고 있어서 패키지 그룹을 설치할 때 사용됨.

`--newest-only`: 최신 버전의 패키지만 다운로드, 따라서 이전 버전의 패키지는 무시

`--download-metadata`: 저장소 메타데이터를 다운로드함. 메타데이터에는 저장소에 있는 패키지 목록 및 정보가 포함됨

#### 2. createrepo
RPM 패키지들의 목록과 속성을 포함합니다. 메타데이터를 생성함. 위에서 설명한 repodata 디렉토리, repomd.xml 을 생성함

```bash
createrepo -v <dir>
```
두개의 명령어를 활용하여 레포를 생성할때 아래와 같이 생성 할 수 있음

```bash
echo ""
echo "       reposync from epel ..."
echo ""
dnf reposync --delete --repoid=epel --download-path=/var/www/html/repo/rocky-9/ --downloadcomps --newest-only --download-metadata
#dnf reposync --repoid=appstream --download-path=/var/www/html/repo/rocky-8/ --downloadcomps --download-metadata
cd /var/www/html/repo/rocky-9/epel/
createrepo -v  /var/www/html/repo/rocky-9/epel/
```

위 예시는 /var/www/html/ 디렉토리 밑에 생성하고 아파치 데몬을 실행하여 80 포트로 타 서버에서 repo 서비스를 사용 할 수 있도록 만든 예시임

---

## yum 사용시 유용한 명령어
```bash
# 패키지 설치
yum install [패키지 이름]

# 패키지 삭제
yum remove

# 패키지 업데이트
yum update

# 패키지 업그레이드, update와 다르게 설치되어있는 패키지의 의존성 패키지까지 설치 및 업데이트를 함
yum upgrade

# 설치 가능한, 설치 되어있는 패키지 리스트 출력
yum list

# yum repo의 repomd.xml 을 다운하여 서버에서 레포리스트를 갱신함
yum makecache

# 특쟁 패키지 검색
yum search [검색어]

# 패키지 캐시를 삭제
yum clean

# 패키지의 정보와 의존성패키지 확인
yum info

# 특정 패키지를 이전 버전으로 다운그레이드
yum downgrade [패키지명]

# yum 명령어 실행 history 를 출력함
yum history
ID     | 명령행                                                      | 날짜와 시간      | 작업           | 변경됨
------------------------------------------------------------------------------------------------------------------
    11 | install sqlite                                              | 2024-04-04 00:38 | Install        |    1
    10 | install nginx-filesystem                                    | 2024-04-01 11:20 | Install        |    1
     9 | install ./remi-release-9.rpm                                | 2024-03-29 04:01 | Install        |    1
     8 | update                                                      | 2024-03-27 00:42 | I, U           |  136 E<
     7 | install epel-release                                        | 2024-03-14 00:56 | Install        |    1 >E
     6 | install createrepo                                          | 2024-03-13 22:27 | Install        |    2
     5 | install traceroute                                          | 2024-01-19 01:00 | Install        |    1
     4 | install httpd                                               | 2024-01-11 01:26 | Install        |   11
     3 | install iptables-services iptables-utils                    | 2024-01-11 01:18 | Install        |    2
     2 | update                                                      | 2024-01-10 02:31 | I, U           |  437 E<
     1 |                                                             | 2024-01-10 10:56 | Install        | 1186 >E

# yum 명령어 실행 history 중 특정 실행내역을 자세히 표시함
yum history info [id]
연결 ID : 4
시작 시간 : 2024년 01월 11일 (목) 오전 01시 26분 19초
rpmdb 시작 : 20200ee45739b4d8c8b1da64b33b0d80a6f2bee14e08a8971201bb6f58f42ced
종료 시간 : 2024년 01월 11일 (목) 오전 01시 26분 20초 (1 초)
rpmdb 종료: 671b31d67ef974e1b397dd27618749747ef7d92c4596383cfa82571b27ac4173
사용자            : smilecsap <smilecsap>
반환 코드 : 성공
배포버전     : 9
명령 줄   : install httpd
댓글        :
변경된 꾸러미 :
    설치 rocky-logos-httpd-90.14-2.el9.noarch @appstream
    설치 mod_lua-2.4.57-5.el9.x86_64          @appstream
    설치 httpd-tools-2.4.57-5.el9.x86_64      @appstream
    설치 httpd-2.4.57-5.el9.x86_64            @appstream
    설치 httpd-filesystem-2.4.57-5.el9.noarch @appstream
    설치 apr-util-openssl-1.6.1-23.el9.x86_64 @appstream
    설치 apr-util-bdb-1.6.1-23.el9.x86_64     @appstream
    설치 apr-util-1.6.1-23.el9.x86_64         @appstream
    설치 mod_http2-1.15.19-5.el9.x86_64       @appstream
    설치 apr-1.7.0-12.el9_3.x86_64            @appstream
    설치 httpd-core-2.4.57-5.el9.x86_64       @appstream


# yum 명령어 실행 내용중 특정 기간 이전으로 롤백함
yum history undo [id]

# yum update가 가능한 패키지를 검색함
yum check-update
```

---

## 특정 패키지의 버전을 고정하는법

1. 우선 패키지의 현재 버전을 확인. yum info 명령어를 사용
```bash
yum info httpd
```
2. /etc/yum.conf 파일에 아래 내용 추가
```bash
exclude=httpd*
```
httpd* 대신에 고정시키고자 하는 패키지 버전을 입력

3. 업데이트 수행, 패키지가 고정되어 있으므로 "yum update" 명령을 실행하여 다른 패키지들은 업데이트되지만 해당 패키지는 업데이트되지 않음
```bash
yum update
```
