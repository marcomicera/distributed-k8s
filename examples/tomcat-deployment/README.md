# What is this

This is a simple Kubernetes demo from [this tutorial](https://youtu.be/gpmerrSpbHg?t=1801) ([repo](https://github.com/LevelUpEducation/kubernetes-demo)).\
The `.yaml` file we're about to deploy is this: [`deployment.yaml`](deployment.yaml):
```yaml
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: tomcat-deployment
spec:
  selector:
    matchLabels:
      app: tomcat
  replicas: 1
  template:
    metadata:
      labels:
        app: tomcat
    spec:
      containers:
      - name: tomcat
        image: tomcat:9.0
        ports:
        - containerPort: 8080

```

## Applying the `.yaml` deployment file
```bash
$ kubectl apply -f ./deployment.yaml 
deployment.apps/tomcat-deployment created
```

## Exposing the deployment as a service
```bash
$ kubectl expose deployment tomcat-deployment --type=NodePort
service/tomcat-deployment exposed
```

## Retrieving its URL
```bash
$ minikube service tomcat-deployment --url
http://192.168.99.102:32475
$ curl $(minikube service tomcat-deployment --url)
curl: (7) Failed to connect to 192.168.99.102 port 32475: Connection refused
```
What's going on? Retrieving info:
```bash
$ kubectl describe pod tomcat-deployment
Name:           tomcat-deployment-75cc77755c-985zq
Namespace:      default
Priority:       0
Node:           minikube/10.0.2.15
Start Time:     Tue, 17 Sep 2019 10:23:52 +0200
Labels:         app=tomcat
                pod-template-hash=75cc77755c
Annotations:    <none>
Status:         Pending
IP:             
Controlled By:  ReplicaSet/tomcat-deployment-75cc77755c
Containers:
  tomcat:
    Container ID:   
    Image:          tomcat:9.0
    Image ID:       
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-lj598 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  default-token-lj598:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-lj598
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  8m13s  default-scheduler  Successfully assigned default/tomcat-deployment-75cc77755c-985zq to minikube
  Normal  Pulling    8m12s  kubelet, minikube  Pulling image "tomcat:9.0"
```
It is still pulling the `"tomcat:9.0"` image. Let's wait for it to be done.

