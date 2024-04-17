

## Ubuutnu 22.04 repo 서버 구축

**repo 서버및 client os정보**

- repo 서버 및 client

  ```bash
  DISTRIB_ID=Ubuntu
  DISTRIB_RELEASE=22.04
  DISTRIB_CODENAME=jammy
  DISTRIB_DESCRIPTION="Ubuntu 22.04 LTS"
  PRETTY_NAME="Ubuntu 22.04 LTS"
  NAME="Ubuntu"
  VERSION_ID="22.04"
  VERSION="22.04 (Jammy Jellyfish)"
  ```

---

**repo서버 apt mirror 설치**

- galera cluster repository와 ubuntu repository를 구성 할 예정이기때문에 두개의 repository를 mirror.list에 추가하여 repository를 sync한다.:wq

```bash
root@kimbh0132-206594:/# apt install apt-mirror
root@kimbh0132-206594:/# mv /etc/apt/mirror.list >> /etc/apt/mirror.list.bak
root@kimbh0132-206594:/# cat > /etc/apt/mirror.list.bak << EOF
# galeracluster repo
deb https://releases.galeracluster.com/galera-4/ubuntu jammy main
deb https://releases.galeracluster.com/mysql-wsrep-8.0/ubuntu jammy main
# jammy repo
deb http://mirror.kakao.com/ubuntu/ jammy main restricted universe multiverse
deb http://mirror.kakao.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirror.kakao.com/ubuntu/ jammy-backports main restricted universe multiverse
deb http://mirror.kakao.com/ubuntu jammy-security main restricted universe multiverse
EOF

root@kimbh0132-206594:/# apt-mirror
Downloading 18 release files using 18 threads...
Begin time: Wed May 24 14:26:35 2023
[18]... [17]... [16]... [15]... [14]... [13]... [12]... [11]... [10]... [9]... [8]... [7]... [6]... [5]... [4]... [3]... [2]... [1]... [0]...
~
~
```

기본적으로 ' /var/spool/ ' 아래에 다운로드되며 다운로드 위치를 변경하고자 하면 mirror.list 에 해당 옵션을 추가하면된다.

```bash
set base_path    /var/spool/apt-mirror # 디렉토리 위치
```

repo 확인 명령어

```bash
apt-cache policy mysql-client
```

