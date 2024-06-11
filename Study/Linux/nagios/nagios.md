---
title: vim_단축키
tags: 
date: 2024_05_30
Modify_Date: 
reference: 
link:
---

idchowto 참고 글

https://idchowto.com/nagios-%ed%85%94%eb%a0%88%ea%b7%b8%eb%9e%a8-%eb%b6%84%eb%a6%ac/

```bash
## Step 1: Update system packages
$ sudo apt update && sudo apt upgrade -y

## Step 2: Install required dependencies
$ sudo apt install wget unzip curl openssl build-essential libgd-dev libssl-dev libapache2-mod-php php-gd php apache2

## Step 3: Download Nagios setup file
$ wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz

## Step 4: Unzip the setup file
$ sudo tar -zxvf nagios-4.4.6.tar.gz

## Step 5: Execute configure script
$ sudo ./configure
$ sudo make all

## Step 6: 사용자 생성
# Nagios를 설치하고 사용하기 전에 그룹과 사용자를 생성
$ sudo make install-groups-users
groupadd -r nagios
useradd -g nagios nagios
# 위 이름으로 apache에서 이름이 nagios인 그룹을 추가

## Step 7: Nagios 설치
$ sudo make install
$ sudo make install-commandmode

## Step 8 : config 설치
$ sudo make install-config

## Step 9 : Apache 용 구성 파일 설치
$ sudo make install-webconf
# a2enmod 명령을 사용하여 rewrite 모듈을 허용
$ sudo a2enmod rewrite
$ suod a2enmod cgi

## Step 10 : 방화벽 설정
$ sudo ufw allow apache
$ sudo ufw enable
$ sudo ufw reload
# Apache 재시작
$ sudo systemctl restart apache2

## Step 11 : 새 사용자 만들기
# Nagios 를 사용하기 위해서는 새로운 Nagios 사용자와 비밀번호를 생성하여야함.
$ sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users itslinuxfoss

## Step 12 : Nagios 플러그인 설치
$ sudo wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
$ cd nagios-plugins-2.3.3
$ sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios
$ sudo make install

```



