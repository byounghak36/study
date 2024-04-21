![사진1](regular-expression.gif)

# 정규 표현식(regular expression, regexp, regex)이란?  
정규표현식은 문자형 데이터를 다루는 기법중 하나이며 리눅스 뿐만 아니라 다양한 언어에서도 활용되고 있다. 정규표현식을 사용한다면 간단하게 원하는 결과를 얻을 수 있다는 장점이 있습니다. 하지만 다양한 문자를 결합해 사용하는만큼 가독성이 떨어지고 자칫하면 다른 사람이 보았을때 이해하기 어려울 수 있다는 단점이 있습니다.  
그렇다 하더라도 특정 상황에서는 여러 명령어 또는 함수를 사용하는것보다 정규표현식이 간편한 경우도 있기에 공부했었던 내용을 글로서 정리해 두려 합니다.  
리눅스에서 정규 표현식과 관련된 유틸리티로는 grep, sed, awk 등이 있으며 해당 문서에서는 grep 명령어를 사용하여 정규 표현식을 설명하려 합니다.  
- grep: 유닉스에서 가장 기본적인 REGEX 평가 유틸리티. Global Regualr Expression Print의 약어
- sed: stream editor로, REGEX 기능을 일부 탑재
- awk: 패턴식 다루기 가능한 언어툴로, 프로그래밍 언어의 일종. 문자열 관련한 방대한 기능 가짐
  
정규 표현식에도 여러 종류가 있으며 대표적으로는 POSIX REGEX, PCRE 두 개가 있습니다.

## 정규 표현식의 종류  
1. POSIX REGEX  
   - 이식 가능 운영 체제 인터페이스( Portable Operating System Interface )의 약자로, 서로 다른 UNIX OS의 공통 API를 정리해 이식성이 높은 유닉스 응용 프로그램을 개발하기 위해 IEEE가 책정한 애플리케이션 인터페이스 규격입니다.   간단한 패턴 매칭에 사용하며, 복잡한 패턴에서는 약간의 성능 저하가 발생할 수도 있습니다. 하지만 이 표현이 표준이므로 POSIX 표현식부터 배우는 것이 좋습니다.   이는 다시 BRE(Basic RE)와 ERE(Extended RE)로 기법이 나뉩니다. BRE는 grep 작동의 기본 값입니다. 아무 옵션을 적지 않으면 BRE를 기본으로 작동합니다. ERE는 기능적으로는 같으나 더 많은 표현식과 편의성을 제공하며, egrep의 기본값 입니다.
   - 아래는 BRE와 ERE의 메타문자 종류 입니다.
    
    | RE 패턴 	| ERE 패턴 	| 설명 	| 예 	|
    |:---:	|:---:	|:---:	|:---:	|
    | . 	| . 	| 임의의 한 문자 	| a.b : aab, abb, acb, ... 	|
    | * 	| * 	| 선행 문자 패턴이 0개 이상 	| ab* : a, ab, abb, ... 	|
    | \+ 	| + 	| 선행 문자 패턴이 1개 이상 	| ab+ : ab, abb, abbb, ... 	|
    | \? 	| ? 	| 선행 문자 패턴이 0~1 개 	| ab? : a, ab 	|
    | \{n,m\} 	| {n,n} 	| 선행 문자 패턴이 n~m개 	| a{2,4} : aa, aaa, aaaa 	|
    | ^ 	| ^ 	| 행의 끝 	| a^ : a, ba, bba, ... 	|
    | $ 	| $ 	| 행의 시작 	| $a : a, aa, ab, abc, ... 	|
    | [...] 	| [...] 	| [ ]안의 문자들 중 한 문자 	| [abc] : a, b, c 	|
    | [^...] 	| [^...] 	| [ ]안의 문자들이 아닌 문자들 중 한 문자 	| [^abc] : d, e, f, ... 	|
    | \ 	| \ 	| 메타문자의 의미를 제거/생성 	| a\.b : a.b 	|
    | \| 	| \| 	| or 	| a\|b\|c : a, b, c 	|
    | \(...\) 	| (...) 	| 그룹의 	| (ab)+ : ab, abab, ababab, ... 	|
    | \num 	| \num 	| num번째 그룹 래퍼런스 	| ([0-9])-\1 : 1-1, 21-21, 123-123, ... 	|

2. PCRE
   - Perl Compatible Regualr Expression의 약어로, Perl에서 제공되던 REGEX가 우수하여 다른 언어에서도 제공하기 위해 만들어졌습니다. C언어로 만들어져 있으며, POSIX REGEX에 추가된 확장 기능 가지고 성능이 더 좋습니다.  C, C++, Python 등에서 추가 라이브러리의 형태로 대부분의 언어에서 지원됩니다.

---
  
# grep 사용 방법
grep 을 실행할 때는 matcher(matching 을 실행하는 엔진)을 고를 수 있습니다.

| **matcher** |               **설명**               |
|:-----------:|:-----------------------------------:|
|      -G     | 디폴트 값으로, BRE를 사용해 작동          |
|      -E     | ERE를 사용해 작동. egrep 작동값과 동일    |
|      -P     | PCRE 사용해 작동. pcre2grep 작동값과 동일 |
|      -F     | 고정 길이 문자열 탐색 모드. 잘 안 씀      |

- 예제로 사용할 텍스트
    ```
    kimbh@kimbh:~$ cat sample 
    apple
    bat
    ball
    ant
    eat
    pant
    peaople
    taste
    @kimbh
    123_abc_d4e5
    xyz123_abc_d4e5
    123_abc_d4e5.xyz
    xyz123_abc_d4e5.xyz
    010-1231-1231
    01012311231
    xyz
    ```
---
## 정규 표현식 예제
- 리터럴 일치  
    grep 명령어의 가장 기본적인 용도는 파일에서 리터럴 문자 또는 일련의 문자를 검색하는 것입니다. 예를 들어 /etc/passwd 파일에 "bash" 문자열이 포함된 모든 줄을 표시하려면 다음 명령을 실행합니다.
    ```
    grep bash /etc/passwd

    # root:x:0:0:root:/root:/bin/bash
    # kimbh:x:1000:1000:kimbh:/home/kimbh:/bin/bash
     ```

    이 예에서 문자열 "bash"는 4개의 리터럴 문자로 구성된 기본 정규식입니다. 그러면 grep에서 "b", "s" 및 "h" 바로 뒤에 "b"가 있는 문자열을 검색하도록 지시합니다.

    \* 리터럴은 데이터(값) 그 자체를 뜻한다. 즉, 변수에 넣는 변하지 않는 데이터를 의미하는 것

- '^'  
    '^' 기호는 줄의 시작 부분에 있는 빈 문자열과 일치합니다. 다음 예제에서 문자열 "linux"는 줄의 맨 처음에 발생하는 경우에만 일치합니다.
    ```
    kimbh@kimbh:~$ grep '^a' sample
    apple
    ant
    ant
    antant
    annt
    ```
    
- $(달러)  
    기호는 줄의 시작 부분에 있는 빈 문자열과 일치합니다. 문자열 "linux"로 끝나는 줄을 찾으려면 다음을 사용합니다.
    ```
    kimbh@kimbh:~$ grep t$ sample
    bat
    ant
    eat
    pant
    ```
    두 앵커를 모두 사용하여 정규식을 구성할 수도 있습니다. 예를 들어, "xyz"만 포함된 줄을 찾으려면 아래와같이 실행합니다.
    ```
    kimbh@kimbh:~$ grep '^xyz$' sample
    xyz
    ```
    또는 모든 빈 줄과 일치하는 값을 추출하는 '^$' 으로도 사용할 수 있습니다.

- '.'(마침표)
    '.' (마침표) 문자의 개수와 일치하는 문자열을 찾습니다. 예를 들어, "ap"으로 시작한 다음 두 개의 문자가 있고 "e" 문자열로 끝나는 항목을 찾으려면 다음 패턴을 사용합니다.
    ```
    kimbh@kimbh:~$ grep 'ap..e' sample
    apple
    ```

- ?(물음표)
    선행문자를 선택사항으로 지정하며 한 번만 일치시킬 수 있습니다. 다음은 "밝음"과 "오른쪽" 모두 일치합니다. 다음과 같은 기본 정규식을 사용하므로 백슬래시를 사용하여 ? 문자를 이스케이프합니다.

    grep 'b\?right' file.txt

- 대괄호 식 '[]'
    대괄호 표현식은 '[ ]' 로 묶어서 문자 그룹을 일치시킬 수 있습니다. 예를 들어, "accept" 또는 "accent"가 포함된 행을 찾는 경우 다음과 같이 사용할 수 있습니다.
    ```
    grep 'acce[np]t' file.txt
    ```
    대괄호 안의 첫 번째 문자로 캐럿(^)을 적은 경우 대괄호 내의 있는 문자는 검색하지 않습니다. 아래와 같이 사용할 경우 "ba"로 시작하는 문자열의 조합은 "batt", "ball"이 있지만 3번째 문자가 t가 아닌 문자만 검색하게 됨으로 "ball"만 출력 됩니다.
    ```
    kimbh@kimbh:~$ grep 'ba[^t]' sample
    ball
    ```

    문자를 하나씩 배치하는 대신 대괄호 안에 문자 범위를 지정할 수 있습니다. 범위 표현식은 하이픈으로 구분된 범위의 첫 번째 및 마지막 문자를 지정하여 구성됩니다. 예를 들어, [a-e]는 [abcde]와 같고 [1-3]은 [123]과 같습니다.
    
    다음 식은 [abcde]로 시작하는 줄을 검색합니다.
    ```
    kimbh@kimbh:~$ grep '^[a-e]' sample
    apple
    bat
    ball
    ant
    eat
    ```

- 구문 클래스(syntax classes)
    grep은 대괄호로 묶인 정의된 문자 클래스도 지원합니다. 다음 표는 가장 일반적인 문자 클래스 중 일부입니다.

    | 구문 클래스 	|      의미      	|
    |:-----------:	|:--------------:|
    |  [:digit:]  	|      숫자       |
    |  [:alpha:]  	|      문자       |
    |  [:alnum:]  	| 문자 또는 숫자 	|
    |  [:upper:]  	|     대문자      |
    |  [:space:]  	|    공백 문자     |
    |  [:xdigit:] 	|   16진수 숫자    |
    |  [:cntrl:]  	|    제어 문자     |
    |  [:ascii:]  	|   ascii 문자    |

 
- 수량자  
    수량자를 사용하면 일치가 발생하기 위해 존재해야 하는 항목의 발생 횟수를 지=할 수 있습니다. 다음 표에서는 GNU grep 에서 지원되는 수량자 입니다.
    |   *    | 선행문자패턴이 0개 이상 반복       |
    |:------:|------------------------------|
    |   ?    | 선행문자패턴이 0개 혹은 1개      |
    |   +    | 선행문자패턴이 1개 이상 반복      |
    |  {n}   | 선행문자패턴이 n번 일치           |
    |  {n,}  | 선행문자패턴이 n번 이상 일치       |
    |  {,m}  | 선행문자패턴이 최대 m번 일치       |
    | {n,m}  | 선행문자패턴이 n번부터 m번까지 일치 |
 

 

다음은 확장 정규식을 사용한 동일한 정규식입니다.

grep -E 'b?right' file.txt
 

 

+(더하기) 문자는 이전 항목과 한 번 이상 일치합니다. 다음은 "ssright"과 "sright"가 일치하지만 "right"은 일치하지 않습니다.

grep -E 's+right' file.txt
 

 

중괄호 문자 {}을(를) 사용하면 일치 발생에 필요한 정확한 숫자, 상한 또는 하한 또는 발생 범위를 지정할 수 있습니다.

다음은 3~9자리 사이의 모든 정수와 일치합니다.

grep -E '[[:digit:]]{3,9}' file.txt
 

 

 

대체
대체라는 용어는 단순 "OR"입니다. 대체 연산자 | (파이프)를 사용하면 리터럴 문자열 또는 식 집합일 수 있는 가능한 다른 일치 항목을 지정할 수 있습니다. 이 연산자는 모든 정규식 연산자 중 우선 순위가 가장 낮습니다.

아래 예에서는 Nginx 로그 오류 파일에서 fatal, error 및 critical이라는 단어가 모두 검색됩니다.

grep 'fatal\|error\|critical' /var/log/nginx/error.log
 

 

확장 정규식을 사용할 경우 아래와 같이 연산자 |를 이스케이프하면 안 됩니다.

grep -E 'fatal|error|critical' /var/log/nginx/error.log
 

 

 

그룹화
그룹화는 패턴을 그룹화하여 하나의 항목으로 참조할 수 있는 정규식의 기능입니다. 그룹은 괄호()를 사용하여 만듭니다.

기본 정규식을 사용할 때는 괄호를 백슬래시(\)로 이스케이프해야 합니다.

다음 예제는 "fearless"과 "less"를 모두 일치시킵니다. ? 정량자는 (두려움) 그룹을 선택 사항으로 만듭니다.

grep -E '(fear)?less' file.txt
 

 

 

특수 백슬래시 표현식
GNU grep에는 백슬래시 뒤에 일반 문자로 구성된 여러 메타 문자가 포함되어 있습니다. 다음 표에서는 가장 일반적인 특수 백슬래시 표현식을 보여 줍니다.

 

\b 단어 경계를 일치시킵니다.

\< 단어의 시작 부분에 빈 문자열을 일치시킵니다.

\> 단어 끝에 빈 문자열을 일치시킵니다.

\w 단어를 일치시킵니다.

\s 공백을 일치시킵니다.

 

다음 패턴은 "abject" 및 "object"의 개별 단어와 일치합니다. 더 큰 단어로 삽입하면 단어와 일치하지 않습니다.

grep '\b[ao]bject\b' file.txt
 

 

정규식은 텍스트 편집기, 프로그래밍 언어 및 grep, sed 및 awk와 같은 명령줄 도구에 사용됩니다. 정규식을 구성하는 방법을 알면 텍스트 파일을 검색하거나 스크립트를 작성하거나 명령 출력을 필터링할 때 매우 유용할 수 있습니다.



-------------
1. '.' 의 개수 만큼 아무 문자나 대체
    ```
    kimbh@kimbh:~$ cat sample | grep "a...."
    apple
    peaople
    ```
2. 문자열의 처음 시작 부분 매칭
    ```
    kimbh@kimbh:~$ cat sample | grep ^a
    apple
    ant
    ```
3. 문자열의 끝 부분 매칭
    ```
    kimbh@kimbh:~$ cat sample | grep t$
    bat
    ant
    eat
    pant
    ```
4. 앞의 문자와 매칭
    ```
    kimbh@kimbh:~$ cat sample_2 | grep xyz*
    xyz123_abc_d4e5
    123_abc_d4e5.xyz
    xyz123_abc_d4e5.xyz

    kimbh@kimbh:~$ cat sample_2 | grep ^xyz*
    xyz123_abc_d4e5
    xyz123_abc_d4e5.xyz
    ```
5. 특수 문자와 매칭
    ```
    kimbh@kimbh:~$ cat sample_2 | grep "\@"
    @kimbh
    ```
6. 정규 표현식 그룹
   - a나 b로 시작하는 모든 행
        ```
        kimbh@kimbh:~$ cat sample | grep ^[ab]
        apple
        bat
        ball
        ant
        ```
   - 0~9 사이로 시작하는 단어
        ```
        kimbh@kimbh:~$ cat sample_2 | grep ^[0-9]
        123_abc_d4e5
        123_abc_d4e5.xyz

        ```
   - x~z 사이 알파벳으로 끝나는 단어
        ```
        kimbh@kimbh:~$ cat sample_2 | grep [x-z]$
        123_abc_d4e5.xyz
        xyz123_abc_d4e5.xyz
        ```

## III.  확장 정규 표현식(ERE, Extended Regular Expressions)
1. 't'앞에 'n'이 있는 문자열 추출
    ```
    kimbh@kimbh:~$ cat sample | grep "n\+t"
    ant
    pant
   
    ```
---
\* Reference  
- blog  
https://rfriend.tistory.com/373  
https://lascrea.tistory.com/100  
https://winterbloooom.github.io/computer%20science/linux/2022/02/25/bash1.html  
https://chartworld.tistory.com/27
- wiki  
https://en.wikibooks.org/wiki/Regular_Expressions/POSIX_Basic_Regular_Expressions