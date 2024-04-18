## ReplicaSet으로 Stateful Pod 관리하기

컨트롤러들은 상태가 유지되지 않는 애플리케이션(Stateless application)을 관리하기 위해 사용된다. Pod가 수시로 리스타트되어도 되고, Pod 내의 디스크 내용이 리스타트되어 유실되는 경우라도 문제가 없는 워크로드 형태이다. 웹서버나 웹애플리케이션 서버 (WAS)등이 그에 해당한다. 그러나 RDBMS나 NoSQL과 같은  분산 데이터 베이스등과 같이 디스크에 데이터가 유지 되어야 하는 상태가 유지되는 애플리케이션 (Stateful application)은 기존의 컨트롤러로 지원하기가 어렵다.

ReplicaSet (이하 RS)를 이용하여 데이터 베이스 Pod를 관리하게 되면 여러가지 문제가 발생한다.

### Pod의 이름
RS 등, Stateless Pod를 관리하는 컨트롤러에 의해서 관리되는 Pod들의 이름은 아래 그림과 같이 그 이름이 불 규칙적으로 지정된다.
![](https://t1.daumcdn.net/cfile/tistory/999AA3505C6578222C)
마스터/슬레이브 구조를 가지는 데이터 베이스등에서 마스터 서버의 이름을 특정 이름으로 지정할 수 가 없다.
### Pod의 기동 순서
RS에 의해서 관리되는 Pod들은 기동이 될때 병렬로 동시에 기동이 된다. 그러나 데이터베이스의 경우에는 마스터 노드가 기동된 다음에, 슬레이브 노드가 순차적으로 기동되어야 하는 순차성을 가지고 있는 경우가 있다. 
### 볼륨 마운트
Pod에 볼륨을 마운트 하려면, Pod는 PersistentVolume (이하 PV)를 PersistentVolumeClaim(이하 PVC)로 연결해서 정의해야 한다.

RS등의 컨트롤러를 사용해서 Pod를 정의하게 되면, Pod 템플릿에 의해서 PVC와 PV를 정의하게 되기 때문에, 여러개의 Pod들에 대해서 아래 그림과 같이 하나의 PVC와 PV만 정의가 된다. RS의 Pod 템플릿에 의해 정의된 Pod들은 하나의 PVC와 연결을 시도 하는데, 맨 처음 생성된 Pod가 이 PVC와 PV에 연결이 되기 때문에 뒤에 생성되는 Pod들은 PVC를 얻지 못해서 디스크를 사용할 수 없게 된다.

![](https://t1.daumcdn.net/cfile/tistory/99A30E395C6578222C)
  
아래 YAML 파일은 위의 내용을 테스트 하기 위해서 작성한 파일이다.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: helloweb-disk
spec:
 accessModes:
   - ReadWriteOnce
 resources:
   requests:
     storage: 30Gi
     
---

apiVersion: v1
kind: ReplicationController
metadata:
 name: nginx
spec:
 replicas: 3
 selector:
   app: nginx
 template:
   metadata:
     name: nginx
     labels:
       app: nginx
   spec:
     containers:
     - name: nginx
       image: nginx:1.7.9
       volumeMounts:
       - name: nginx-data
         mountPath: /data/redis
       ports:
       - containerPort: 8090
     volumes:
     - name: nginx-data
       persistentVolumeClaim:
         claimName: helloweb-disk
```

nginx Pod를 RC를 이용하여 3개를 만들도록 하고, nginx-data 라는 볼륨을 helloweb-disk라는 PVC를 이용해서 마운트 하는 YAML 설정이다. 이 설정을 실행해보면 아래 그림과 같이nginx-2784n Pod 하나만 생성된다. 

![](https://t1.daumcdn.net/cfile/tistory/99E0D6345C6578221E)

`kubectl describe pod nginx-6w9xf ` 명령을 이용해서 다른 Pod가 기동되지 않는 이유를 조회해보면 다음과 같은 결과를 얻을 수 있다. 

![](https://t1.daumcdn.net/cfile/tistory/991A964E5C6578222D)

내용중에 중요한 내용을 보면 다음과 같다. 

```bash
“Multi-Attach error for volume "pvc-d930bfcb-2ec0-11e9-8d43-42010a920009" Volume is already used by pod(s) nginx-2784n”
```

앞에서 설명한 대로, 볼륨(PV)이 다른 Pod (nginx-2784n)에 의해 이미 사용되고 있기 때문에 볼륨을 사용할 수 없고, 이로 인해서, Pod 생성이 되지 않고 있는 상황이다.

RS로 이를 해결 하려면 아래 그림과 같이 Pod 마다 각각 RS을 정의하고, Pod마다 각기 다른 PVC와 PV를 바인딩하도록 설정해야 한다. 

![](https://t1.daumcdn.net/cfile/tistory/991364435C65782228)

그러나 이렇게 Pod 마다 별도로 RS와 PVC,PV를 정의하는 것은 편의성 면에서 쉽지 않다. 

## StatefulSet
그래서 상태를 유지하는 데이터베이스와 같은 애플리케이션을 관리하기 위한 컨트롤러가 StatefulSet 컨트롤러이다. (StatefulSet은 쿠버네티스 1.9 버전 부터 정식 적용 되었다.)

StatefulSet은 앞에서 설명한 RS등의 Stateless 애플리케이션이 관리하는 컨트롤러로 할 수 없는 기능들을 제공한다. 대표적인 기능들은 다음과 같다.

### Pod 이름에 대한 규칙성 부여
StatefulSet에 의해서 생성되는 Pod들의 이름은 규칙성을 띈다. 생성된 Pod들은 {Pod 이름}-{순번} 식으로 이름이 정해진다. 예를 들어 Pod 이름을 mysql 이라고 정의했으면, 이 StatefulSet에 의해 생성되는 Pod 명들은 mysql-0, mysql-1,mysql-2 … 가 된다. 

### 배포시 순차적인 기동과 업데이트
또한 StatefulSet에 의해서 Pod가 생성될때, 동시에 모든 Pod를 생성하지 않고, 0,1,2,.. 순서대로 하나씩 Pod를 생성한다. 이러한 순차기동은 데이터베이스에서 마스터 노드가 기동된 후에, 슬레이브 노드가 기동되어야 하는 조건등에 유용하게 사용될 수 있다. 

### 개별 Pod에 대한 디스크 볼륨 관리
RS 기반의 디스크 볼륨 관리의 문제는 하나의 컨트롤러로 여러개의 Pod에 대한 디스크를 각각 지정해서 관리할 수 없는 문제가 있었는데, StatefulSet의 경우 PVC (Persistent Volume Claim)을 템플릿 형태로 정의하여, Pod 마다 각각 PVC와 PV를 생성하여 관리할 수 있도록 한다. 

그럼 StatefulSet 예제를 보자

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
 name: nginx
spec:
 selector:
   matchLabels:
     app: nginx
 serviceName: "nginx"
 replicas: 3
 template:
   metadata:
     labels:
       app: nginx
   spec:
     terminationGracePeriodSeconds: 10
     containers:
     - name: nginx
       image: k8s.gcr.io/nginx-slim:0.8
       ports:
       - containerPort: 80
         name: web
       volumeMounts:
       - name: www
         mountPath: /usr/share/nginx/html
 volumeClaimTemplates:
 - metadata:
     name: www
   spec:
     accessModes: [ "ReadWriteOnce" ]
     storageClassName: "standard"
     resources:
       requests:
         storage: 1Gi
```

RS나 RC와 크게 다른 부분은 없다. 차이점은 PVC를 volumeClaimTemplate에서 지정해서 Pod마다 PVC와 PV를 생성하도록 하는 부분이다. 위의 볼드처리한 부분

이 스크립트를 실행하면 아래와 같이 Pod가 배포 된다.

![](https://t1.daumcdn.net/cfile/tistory/999DBF375C65782233)

pod의 이름은 nginx-0,1,2,... 식으로 순차적으로 이름이 부여되고 부팅 순서도 0번 pod가 기동되고 나면 1번이 기동되고 다음 2번이 기동되는 식으로 순차적으로 기동된다. 

template에 의해서 PVC가 생성되는데, 아래는 생성된 PVC 목록이다. 이름은 {StatefulSet}-{Pod명} 식으로 PVC가 생성이 된것을 확인할 수 있다. 

![](https://t1.daumcdn.net/cfile/tistory/9978AD385C65782233)

그리고 마지막으로 아래는 PVC에 의해서 생성된 PV(디스크 볼륨)이다.

![](https://t1.daumcdn.net/cfile/tistory/992BD5365C65782233)

### 기동 순서의 조작
위의 예제에 보는것과 같이, StatefulSet은 Pod를 생성할때 순차적으로 기동되고, 삭제할때도 순차적으로 (2→ 1 → 0 생성과 역순으로) 삭제한다. 그런데 만약 그런 요건이 필요 없이 전체가 같이 기동되도 된다면 .spec.podManagementPolicy 를 통해서 설정할 수 있다.

.spec.podManagementPolicy 는 디폴트로 OrderedReady 설정이 되어 있고, Pod가 순차적으로 기동되도록 설정이 되어 있고, 병렬로 동시에 모든 Pod를 기동하고자 하면  Parallel 을 사용하면 된다. 

아래는 위의 예제에서 podManagementPolicy를 Parallel로 바꾼 예제이다. 

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
 name: nginx
spec:
 selector:
   matchLabels:
     app: nginx
 serviceName: "nginx"
 podManagementPolicy: Parallel
 replicas: 3
 template:
   metadata:
     labels:
       app: nginx
   spec:
     terminationGracePeriodSeconds: 10
     containers:
```

## Pod Scale out and in

지금까지 StatefulSet에 대한 개념과 간단한 사용방법에 대해서 알아보았다. 그러면, StatefulSet에 의해 관리되는 Pod가 장애로 인하거나 스케일링 (In/out)으로 인해서 Pod의 수가 늘거나 줄면 그에 연결되는 디스크 볼륨은 어떻게 될까?

예를 들어 아래 그림과 같이 Pod-1,2,3 이 기동되고 있고, 이 Pod들은 StatefulSet에 의해서 관리되고 있다고 가정하자. Pod들은 각각 디스크 볼륨 PV-1,2,3 을 마운트해서 사용하고 있다고 하자. 

![](https://t1.daumcdn.net/cfile/tistory/99611F335C65782227)


이때, Pod-3가 스케일인이 되서, 없어지게 되면, Pod는 없어지지면, 디스크 볼륨을 관리하기 위한 PVC-3는 유지 된다. 이는 Pod 가 비정상적으로 종료되었을때 디스크 볼륨의 내용을 유실 없이 유지할 수 있게 해주고, 오토 스케일링이나 메뉴얼로 Pod를 삭제했을때도 동일하게 디스크 볼륨의 내용을 유지하도록 해준다. 

![](https://t1.daumcdn.net/cfile/tistory/99FE754D5C65782222)

그러면 없앴던 Pod가 다시 생성되면 어떻게 될까? Pod가 다시 생성되면, Pod 순서에 맞는 번호로 다시 생성이 되고, 그 번호에 맞는 PVC 볼륨이 그대로 붙게 되서, 다시 Pod 가 생성되어도 기존의 디스크 볼륨을 그대로 유지할 수 있다. 
## ![](https://t1.daumcdn.net/cfile/tistory/99B8BC4F5C65782213)

출처: [https://bcho.tistory.com/1306](https://bcho.tistory.com/1306) [조대협의 블로그:티스토리]