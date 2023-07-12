1. 安装 gocas 服务  

helm install gocas jibutech/gocas --set config.url=http://<cas-host-ip>:31888

2. 参考以下文档配置kubesphere集群CAS单点登录

https://kubesphere.io/zh/docs/v3.3/access-control-and-account-management/external-authentication/cas-identity-provider/

替换以下两个参数
redirectURL: "http://<ys1000-host-ip>:30880/oauth/redirect/cas"
casServerURL: "http://<cas-host-ip>:31888/cas"

等待并刷新页面，在kubesphere登录页面点击login with cas，使用test1/test1 创建用户并登录，再邀请用户test1到一个workspace的admin

3. 使用helm install 或者 helm upgrade ys1000 时 应用以下 values

```
# cat my-values.yaml

## 参数中ys1000-host-ip与cas-host-ip 可以是安装在同一台集群上的相同ip
tags:
  dex: true

featureGates:
  Tenant: true

dex:
  image:
    repository: registry.cn-shanghai.aliyuncs.com/jibutech/dex
    tag: 1.0.0
    pullPolicy: Always
  service:
    type: NodePort
    ports:
      http:
        port: 5556
        nodePort: 32000
  config:
    issuer: http://<ys1000-host-ip>:32000/dex
    oauth2:
      skipApprovalScreen: true
    storage:
      type: kubernetes
      config:
        inCluster: true
    web:
      http: 0.0.0.0:5556
    staticClients:
    - id: ys1000
      redirectURIs:
      - 'http://<ys1000-host-ip>:30180/login'
      name: 'YS1000'
      secret: ZXmhbABsRS1tcHItcnVjlmVa12u
    enablePasswordDB: true
    staticPasswords:
    - email: "admin@example.com"
      # bcrypt hash of the string "password": $(echo password | htpasswd -BinC 10 admin | cut -d: -f2)
      hash: "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
      username: "admin"
      userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"
    connectors:
    - type: mockCallback
      id: mock
      name: Example
    - type: cas
      id: cas
      name: CAS
      config:
        server: http://<cas-host-ip>:31888/cas/
        redirectURI: http://<ys1000-host-ip>:32000/dex/callback
        insecureSkipVerify: true

   helm upgrade ys1000 ./ys1000 -n ys1000 -f ./ys1000/values.yaml 
```
   
4. 最后登录YS1000，添加kubesphere的host集群为tenant源集群，即可同步该host集群的所有workspace和user
