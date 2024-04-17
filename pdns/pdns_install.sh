

yum install pdns pdns-backend-mysql

# Powerdns 용 계정 생성
MariaDB [(none)]> create database pdns;
MariaDB [(none)]> grant all privileges on pdns.* to 'pdns'@'localhost' identified by 'qwe1212';
MariaDB [(none)]> grant all privileges on pdns.* to 'pdns'@'127.0.0.1' identified by 'qwe1212'
MariaDB [(none)]> flush privileges;

# pdns-backend-mysql을 통해 접속 할 수 있도록 수정
echo ```
launch=gmysql
gmysql-host=127.0.0.1
gmysql-user=pdns
gmysql-password=qwe1212
gmysql-dbname=pdns
``` >> /etc/pdns/pdns.conf

# pdns start
systecmctl start pdns
    # 나의경우 처음에 gmysql-host를 localhost로 해도 될것이라고 생각해서 진행하였음 그러니 아래와같은 에러 발생 및 구동x
    # pdns_server: gmysql Connection failed: Unable to connect to database: Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (13)
    # '/var/lib/mysql/mysql.sock'로 심볼릭 링크도 생성하였지만 해결되지않아, 소켓을 사용하지않고 TCP/IP로 접속하도록 127.0.0.1로 호스트변경, 이후 정상작동함

# PowerAdmin 실행
# - Poweradmin 을 열기위해선 gettext, mcrypt, MDB2 (PowerAdmin 2.1.6 설치 시 필요), pdo_mysql (PowerAdmin 2.1.7 설치 시 필요) 이 필요하다 따라서 플러그인 설치 진행

# - gettext
cd /usr/local/src/php-8.2.1/ext/gettext

phpize
---------------------------------------
Configuring for:
PHP Api Version:         20220829
Zend Module Api No:      20220829
Zend Extension Api No:   420220829
---------------------------------------

cd /usr/local/src/php-8.2.1/
./configure --help | grep gettext
---------------------------------------
--with-gettext[=DIR]    Include GNU gettext support
---------------------------------------

cd /usr/local/src/php-8.2.1/ext/gettext
./configure --with-php-config=/usr/local/php-8.2.1/bin/php-config
make && make install
---------------------------------------
Installing shared extensions:     /usr/local/php-8.2.1/lib/php/extensions/no-debug-zts-20220829/
---------------------------------------

vi /usr/local/apache/conf/php.ini
~
[gettext]
extension=/usr/local/php-8.2.1/lib/php/extensions/no-debug-zts-20220829/gettext.so
~

systecmctl restart apache
php -m | grep gettext

# - MDB2 여기까지함
참고링크 https://susoterran.github.io/other/poweradmin_install/
내서버 : http://115.68.249.230/poweradmin/ (admin/qwe1212)