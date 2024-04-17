- bind 깃허브
https://github.com/isc-projects/bind9

1. install
tar xvfz bind-9.11.3.tar.gz 
cd bind-9.11.3
./configure --prefix=/usr/local/bind --sysconfdir=/etc --localstatedir=/var/named --enable-threads --with-libtool --with-openssl=/usr/local/ssl

- issue_no1
configure: error: libuv not found
대응
yum install epel-release
yum isntall libuv-devel

- issue_no2
configure: error: DNS-over-HTTPS support requested, but libnghttp2 not found. Either install libnghttp2 or use --disable-doh.
구성: 오류: DNS-over-HTTPS 지원이 요청되었지만 libnghttp2를 찾을 수 없습니다. libnghttp2를 설치하거나 --disable-doh를 사용하십시오.
대응
yum install libnghttp2-devel

- issue_no3
configure: error: EVP_DigestSignInit/EVP_DigestVerifyInit support in OpenSSL is manatory.
대응
참고자료 - https://www.openssl.org/docs/man3.0/man3/EVP_DigestVerifyInit.html
openssl1.x.x 에 EVP_DigestSignInit/EVP_DigestVerifyInit함수가 없으며 openssl3.x버전에 추가되었음
openssl3.x 재설치 진행

- issue_no4
configure: error: sys/capability.h header is required for Linux capabilities support. Either install libcap or use --disable-linux-caps.
대응
yum install libcap-devel

make -j `grep processor /proc/cpuinfo' | wc -l`
make install
