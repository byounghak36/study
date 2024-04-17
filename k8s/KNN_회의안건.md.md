- 디플로이먼트 어떤식으로 진행중인지.
- k8s 네트워크 구성
	- 시트로만 보기에는 nodeport만 사용하는 것으로 보임, 모든 pod가 외부로 노출되도록 구성할 예정인지
	- 로드밸런서(MetalLB) 사용하실 예정은 없는지
- 컨테이너 작업 예상도
	- 우리가 생성한 TM,TA,CA 컨테이너 공유
- db서버 레플리케이션 구성(rook-ceph)
	- rook-ceph 구성에 대한 논의 필요
- 레플리카 생성시 소스가 다중 Pod에 용이하게 제작되어있는지
	- 레플리카 구성시 active/acitve 형식으로 구동이 가능한지
---
K-PaaS 진행상황 공유

- K-PaaS 및 GPU-Operator 배포 완료
- Application 설치 전 BaseImage 제작 완료(TM,CA,TA)
