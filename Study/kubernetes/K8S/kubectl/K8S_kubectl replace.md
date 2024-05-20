---
title: K8S_kubectl replace
tags:
  - kubectl
  - kubernetes
date: 2024_05_19
reference: 
link:
---
# K8S_kubectl replace

파일 이름 또는 stdin으로 리소스를 교체합니다.

JSON 및 YAML 형식을 허용합니다. 기존 리소스를 교체하는 경우 전체 리소스 사양을 제공해야 합니다. 이는 다음 명령어를 통해 얻을 수 있습니다:

`kubectl get TYPE NAME -o yaml`
`kubectl replace -f FILENAME`  
예제

- pod.json의 데이터를 사용하여 Pod를 교체합니다:
    `kubectl replace -f ./pod.json`
    
- stdin으로 전달된 JSON을 기반으로 Pod를 교체합니다:
    `cat pod.json | kubectl replace -f -`
    
- 단일 컨테이너 Pod의 이미지 버전(tag)을 v4로 업데이트합니다:
    `kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -`
    
- 강제로 교체하여 리소스를 삭제한 후 다시 생성합니다:
    `kubectl replace --force -f ./pod.json`

옵션

- `--allow-missing-template-keys` 기본값: `true` 템플릿에서 필드나 맵 키가 누락된 경우 오류를 무시합니다. 이는 golang 및 jsonpath 출력 형식에만 적용됩니다.
    
- `--cascade` 문자열[="background"] 기본값: "background" 종속 항목(예: ReplicationController가 생성한 Pod)에 대한 삭제 연쇄 전략을 선택합니다. 기본값은 background입니다.
    
- `--dry-run` 문자열[="unchanged"] 기본값: "none" "none", "server" 또는 "client" 중 하나여야 합니다. client 전략인 경우 보낼 객체만 출력하고 보내지 않습니다. server 전략인 경우 리소스를 지속하지 않고 서버 측 요청을 제출합니다.
    
- `--field-manager` 문자열 기본값: "kubectl-replace" 필드 소유권을 추적하는 데 사용되는 관리자 이름입니다.
    
- `-f, --filename` 문자열 교체할 구성 파일을 포함하는 파일입니다.
    
- `--force` true인 경우 API에서 즉시 리소스를 제거하고 우아한 삭제를 우회합니다. 일부 리소스의 즉각적인 삭제는 일관성 상실이나 데이터 손실을 초래할 수 있으며 확인이 필요합니다.
    
- `--grace-period` 정수 기본값: -1 리소스가 우아하게 종료되도록 허용되는 시간(초)입니다. 음수인 경우 무시됩니다. 즉각적인 종료를 위해 1로 설정할 수 있습니다. --force가 true일 때만 0으로 설정할 수 있습니다(강제 삭제).
    
- `-h, --help` replace 명령어에 대한 도움말을 표시합니다.
    
- `-k, --kustomize` 문자열 kustomization 디렉토리를 처리합니다. 이 플래그는 -f 또는 -R과 함께 사용할 수 없습니다.
    
- `-o, --output` 문자열 출력 형식입니다. (json, yaml, name, go-template, go-template-file, template, templatefile, jsonpath, jsonpath-as-json, jsonpath-file) 중 하나입니다.
    
- `--raw` 문자열 서버에 PUT할 원시 URI입니다. kubeconfig 파일에 지정된 전송 방식을 사용합니다.
    
- `-R, --recursive` -f, --filename에 사용된 디렉토리를 재귀적으로 처리합니다. 관련 매니페스트를 동일한 디렉토리에 정리하여 관리하려는 경우 유용합니다.
    
- `--save-config` true인 경우 현재 객체의 구성을 주석에 저장합니다. 그렇지 않으면 주석이 변경되지 않습니다. 이 플래그는 나중에 이 객체에 대해 kubectl apply를 수행하려는 경우 유용합니다.
    
- `--show-managed-fields` true인 경우 객체를 JSON 또는 YAML 형식으로 출력할 때 managedFields를 유지합니다.
    
- `--subresource` 문자열 지정된 경우, 요청된 객체의 하위 리소스에 대해 replace를 실행합니다. [status scale] 중 하나여야 합니다. 이 플래그는 베타 버전이며 추후 변경될 수 있습니다.
    
- `--template` 문자열 -o=go-template, -o=go-template-file 옵션을 사용할 때 템플릿 문자열 또는 템플릿 파일의 경로입니다. 템플릿 형식은 golang 템플릿입니다 [[http://golang.org/pkg/text/template/#pkg-overview](http://golang.org/pkg/text/template/#pkg-overview)].
    
- `--timeout` 기간 삭제를 포기하기 전에 기다리는 시간입니다. 0은 객체 크기에 따라 시간 초과를 결정합니다.
    
- `--validate` 문자열[="strict"] 기본값: "strict" "strict"(또는 true), "warn", "ignore"(또는 false) 중 하나여야 합니다. "true" 또는 "strict"는 입력을 유효성 검사하고 잘못된 경우 요청을 실패시킵니다. 서버 측 필드 유효성 검사가 api-server에서 활성화된 경우 서버 측 유효성 검사를 수행하지만, 활성화되지 않은 경우 신뢰할 수 없는 클라이언트 측 유효성 검사로 대체합니다. "warn"은 api-server에서 서버 측 필드 유효성 검사가 활성화된 경우 알 수 없거나 중복된 필드에 대해 경고하며, 요청을 차단하지 않습니다. 그렇지 않은 경우 "ignore"처럼 동작합니다. "false" 또는 "ignore"는 스키마 유효성 검사를 수행하지 않으며, 알 수 없거나 중복된 필드를 조용히 무시합니다.
    
- `--wait` true인 경우 리소스가 사라질 때까지 기다린 후 반환합니다. 이는 finalizer를 기다립니다.
    
- `--as` 문자열 작업에 대해 가장할 사용자 이름입니다. 사용자는 일반 사용자이거나 네임스페이스의 서비스 계정일 수 있습니다.
    
- `--as-group` 문자열 작업에 대해 가장할 그룹입니다. 이 플래그는 여러 그룹을 지정하기 위해 반복할 수 있습니다.
    
- `--as-uid` 문자열 작업에 대해 가장할 UID입니다.
    
- `--cache-dir` 문자열 기본값: "$HOME/.kube/cache" 기본 캐시 디렉토리입니다.
    
- `--certificate-authority` 문자열 인증 기관의 인증서 파일 경로입니다.
    
- `--client-certificate` 문자열 TLS를 위한 클라이언트 인증서 파일 경로입니다.
    
- `--client-key` 문자열 TLS를 위한 클라이언트 키 파일 경로입니다.
    
- `--cloud-provider-gce-l7lb-src-cidrs` cidrs 기본값: 130.211.0.0/22,35.191.0.0/16 L7 LB 트래픽 프록시 및 상태 확인을 위한 GCE 방화벽에서 열리는 CIDR입니다.
    
- `--cloud-provider-gce-lb-src-cidrs` cidrs 기본값: 130.211.0.0/22,209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 L4 LB 트래픽 프록시 및 상태 확인을 위한 GCE 방화벽에서 열리는 CIDR입니다.
    
- `--cluster` 문자열 CLI 요청에 사용할 kubeconfig 클러스터 이름입니다.
    
- `--context` 문자열 CLI 요청에 사용할 kubeconfig 컨텍스트 이름입니다.
    
- `--default-not-ready-toleration-seconds` 정수 기본값: 300 notReady:NoExecute에 대한 기본적으로 모든 Pod에 추가되는 tolerationSeconds를 나타냅니다.
    
- `--default-unreachable-toleration-seconds` 정수 기본값: 300 unreachable:NoExecute에 대한 기본적으로 모든 Pod에 추가되는 tolerationSeconds를 나타냅니다.
    
- `--disable-compression` true인 경우 서버에 대한 모든 요청에 대해 응답 압축을 사용하지 않습니다.
    
- `--insecure-skip-tls-verify` true인 경우 서버의 인증서를 유효성 검사하지 않습니다. 이를 통해 HTTPS 연결이 안전하지 않게 됩니다.
    
- `--kubeconfig` 문자열 CLI 요청에 사용할 kubeconfig 파일 경로입니다.
    
- `--match-server-version` 서버 버전이 클라이언트 버전과 일치해야 합니다.
    
- `-n, --namespace` 문자열 이 CLI 요청의 네임스페이스 범위입니다.
    
- `--password` 문자열 API 서버에 대한 기본 인증 비밀번호입니다.
    
- `--profile` 문자열 기본값: "none" 캡처할 프로파일 이름입니다. (none|cpu|heap|goroutine|threadcreate|block|mutex) 중 하나입니다.
    
- `--profile-output` 문자열 기본값: "profile.pprof" 프로파일을 작성할 파일 이름입니다.
    
- `--request-timeout` 문자열 기본값: "0" 단일 서버 요청을 포기하기 전에 기다리는 시간입니다. 0이 아닌 값에는 해당 시간 단위(예: 1s, 2m, 3h)가 포함되어야 합니다. 0의 값은 요청이 시간 초과되지 않음을 의미합니다.
    
- `-s, --server` 문자열