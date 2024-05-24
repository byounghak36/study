---
title: K8S_secret-key 생성
tags: 
date: 2024_05_24
reference:
  - https://nirsa.tistory.com/148
link:
---
# 쿠버네티스 secret 생성

쿠버네티스의 마스터 노드에서 아래와 같이 명령어를 입력 해줍니다. []으로 묶어준 부분들은 모두 상황에 따라 작성 해주셔야 하는 부분 입니다. 아래 내용을 참고하여 커맨드 작성 후 엔터를 치시면 secret이 생성된걸 확인할 수 있습니다.

- [secret name] 은 위에서 작성했던 매니페스트 파일에 기입한 name을 작성해주셔야 합니다. (~ImagePullSecrets.name 부분에 작성한 내용으로, 저같은 경우 dockersecret 이 됩니다.)
- Docker Hub 계정과 패스워드는 실제로 Private Image가 등록되어 있는 Docker Hub의 계정과 패스워드를 작성해주어야 합니다.

## 작성예시
```yaml
    spec:
      containers:
      - name: my-nginx
        image: nirsa/nginx		## docker hub 이미지 지정
        ports:
        - containerPort: 80
      imagePullSecrets:			## 참조할 secret name
      - name: dockersecret
```