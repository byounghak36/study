# grep 명령어
     
리눅스에서 grep 명령어는 특정 파일에서 원하는 문자열 또는 정규표현식을 포함한 행을 출력해주는 명렁어다. tail, ls, cat 등 다양한 명령어와 조합되어 응용되는 경우가 많고, 유용한 옵션이 많이 있어 매우 유용한 명령어다.

---

## 지원하는 옵션

**grep [OPTION...] PATTERN [FILE...]**

```
 -E : PATTERN을 확장 정규 표현식(Extended RegEx)으로 해석.
 -F : PATTERN을 정규 표현식(RegEx)이 아닌 일반 문자열로 해석.
 -G : PATTERN을 기본 정규 표현식(Basic RegEx)으로 해석.
 -P : PATTERN을 Perl 정규 표현식(Perl RegEx)으로 해석.
 -e : 매칭을 위한 PATTERN 전달.
 -f : 파일에 기록된 내용을 PATTERN으로 사용.
 -i : 대/소문자 무시.
 -v : 매칭되는 PATTERN이 존재하지 않는 라인 선택.
 -w : 단어(word) 단위로 매칭.
 -x : 라인(line) 단위로 매칭.
 -z : 라인을 newline(\n)이 아닌 NULL(\0)로 구분.
 -m : 최대 검색 결과 갯수 제한.
 -b : 패턴이 매치된 각 라인(-o 사용 시 문자열)의 바이트 옵셋 출력.
 -n : 검색 결과 출력 라인 앞에 라인 번호 출력.
 -H : 검색 결과 출력 라인 앞에 파일 이름 표시.
 -h : 검색 결과 출력 시, 파일 이름 무시.
 -o : 매치되는 문자열만 표시.
 -q : 검색 결과 출력하지 않음.
 -a : 바이너리 파일을 텍스트 파일처럼 처리.
 -I : 바이너리 파일은 검사하지 않음.
 -d : 디렉토리 처리 방식 지정. (read, recurse, skip)
 -D : 장치 파일 처리 방식 지정. (read, skip)
 -r : 하위 디렉토리 탐색.
 -R : 심볼릭 링크를 따라가며 모든 하위 디렉토리 탐색.
 -L : PATTERN이 존재하지 않는 파일 이름만 표시.
 -l : 패턴이 존재하는 파일 이름만 표시.
```
---

## 명령어 사용 예시 및 응용

1. 단일 파일에서 지정된 문자열 검색
```
root@kimbh:/var/log# grep "error" dmesg
[    2.786120] kernel: ACPI Error: Aborting method \_SB.PCI0.GPP0.VGA.LCD._BCM due to previous error (AE_NOT_FOUND) (20210730/psparse-529)
[    2.792819] kernel: ACPI Error: Aborting method \_SB.PCI0.GP17.VGA.LCD._BCM due to previous error (AE_NOT_FOUND) (20210730/psparse-529)
[    4.234613] kernel: usb 5-1.2: device descriptor read/64, error -32
[    6.965599] kernel: EXT4-fs (sda2): re-mounted. Opts: errors=remount-ro. Quota mode: none.
```
- 시스템 운영자라면 위와같이 특정로그에서 error 메시지를 필터링할때 유용하게 사용할 수 있다.

2. 복수 파일에서 지정된 문자열 검색
```
root@kimbh:/var/log# grep "error" dmesg syslog
dmesg:[    2.786120] kernel: ACPI Error: Aborting method \_SB.PCI0.GPP0.VGA.LCD._BCM due to previous error (AE_NOT_FOUND) (20210730/psparse-529)
dmesg:[    2.792819] kernel: ACPI Error: Aborting method \_SB.PCI0.GP17.VGA.LCD._BCM due to previous error (AE_NOT_FOUND) (20210730/psparse-529)
dmesg:[    4.234613] kernel: usb 5-1.2: device descriptor read/64, error -32
dmesg:[    6.965599] kernel: EXT4-fs (sda2): re-mounted. Opts: errors=remount-ro. Quota mode: none.
syslog:Mar 20 08:15:47 kimbh cinnamon-screensaver-pam-helper: pam_ecryptfs: seteuid error
syslog:Mar 20 10:28:10 kimbh cinnamon-screensaver-pam-helper: pam_ecryptfs: seteuid error
syslog:Mar 20 10:28:53 kimbh pulseaudio[54745]: X11 I/O error handler called
syslog:Mar 20 10:28:53 kimbh pulseaudio[54745]: X11 I/O error exit handler called, preparing to tear down X11 modules
~
```
- 복수 파일도 지정이 가능하다

---

**이정도만 알아두고 나머지는 상단에 있는 옵션과 조합하면 된다.**

**grep 의 또 하나의 장점은 정규표현식을 지원하는것이다. 아래 예시를 확인하자**

1. 특정 단어(Opening)가 포함된 라인
```
$ grep 'Opening' test.txt
특정 단어(Open)로 시작하는 라인 찾기
grep '^Open' test.txt
```
2. 특정 단어(up)로 끝나는 라인 찾기
```
grep 'up$' test.txt
```
3. 특정 단어(a)와 바로 뒤 한글자로 이루어진 라인 찾기
Ex) ab, ac, ad
```
grep 'a.' test.txt
```
4. 소문자가 아닌 대문자가 있는 라인 찾기
```
grep '[^a-z]' test.txt
```
5. 대문자, 소문자 그리고 공백 이후 소문자가 연이어 나오는 라인 찾기
```
grep '[A-Z][a-z] [a-z]' test.txt
```
6. 소문자 a가 나오고 바로 뒤에 b가 0번 또는 N번 나온 후에 공백이 연이어 나오는 라인 찾기
```
grep 'ab* ' test.txt'
```
7. OR 조건으로 찾기
```
ex) grep ‘got|to’ test.txt (got 또는 to가 포함된 라인)
grep 'pattern1\|pattern2' test.txt
```
8. AND 조건으로 찾기
```
ex) grep -E ‘got.*to’ test.txt (got 또는 to가 모두 포함된 라인)
grep -E pattern1.*pattern2 test.txt
```