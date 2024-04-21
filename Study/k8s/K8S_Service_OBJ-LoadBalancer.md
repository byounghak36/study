# K8S_Service_OBJ-LoadBalancer

LoadBalancer 타입의 서비스는 AWS 와 같은 클라우드 플랫폼에서도 제공되지만, 필요시 온프레미스 환경에서 LoadBalancer 타입을 사용할 수 있습니다. 쿠버네티스가 이 기능을 직접 제공하는 것은 아니며, MetalLB나 오픈스택과 같은 특수한 환경을 구축해야만 합니다. 그중에서 MetalLB라는 이름의 오픈소스 프로젝트를 사용하면 쉽게 LoadBalancer 타입의 서비스를 사용할 수 있습니다.
이 글에서는 MetalLB가 설치되어있는 상황에서 해당 기능을 사용하는 방법을 설명합니다.
