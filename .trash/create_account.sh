#!/bin/bash

# 추가할 계정리스트
accounts=(
"kimbh0132"
#"koreav"
#"content173"
#"ajh3696"
#"oops"
#"wnwls648"
"sakamaka"
)

password="qwea\`1//"

for account in "${accounts[@]}"; do
    if id "$account" &>/dev/null; then
        echo "계정 '$account'은(는) 이미 존재합니다."
    else
        useradd -m "$account" -s /bin/bash
        echo "$account:$password" | sudo chpasswd
        passwd -e "$account"
        echo "계정 '$account'이(가) 생성되었습니다."
	chage -d `date +%Y-%m-%d` $account
    fi
done

echo "모든 계정이 처리되었습니다."
