# log collection

YS1000 deploys its components in `qiming-migration` namespace by default. 
NOTE: namespace can be changed by customized helm install.

Velero is installed in `qiming-backend` on each kubernetes cluster. 

## collect logs for YS1000 components

```bash

# install log collector under YS1000 namespace
[root@gyj-dev ~]# kubectl apply -f ./server-log-collector.yaml

# check log collector pod status
[root@gyj-dev ~]# kubectl -n qiming-migration get pods
NAME                                                READY   STATUS    RESTARTS   AGE
log-collector-74c865f9-bb8xg                        1/1     Running   0          36m
mig-controller-default-58ff75688c-g8rlj             1/1     Running   0          11h
qiming-operator-94fcbbd57-6wg6c                     1/1     Running   0          11h
qiming-operator-velero-installer-78ddb79499-d8rbw   1/1     Running   0          11h
ui-discovery-default-cdc8774bf-2rvpb                2/2     Running   0          11h

# log in log collector pod 
[root@gyj-dev ~]# k -n qiming-migration exec -it log-collector-74c865f9-bb8xg -- sh

# run collector command
(app-root) sh-4.4$ python /qiming/log-collector.py
(app-root) sh-4.4$ python /qiming/log-collector.py
Create logpath /tmp/qiming-migration-logs-1634224404.41/qiming-migration
Create logpath /tmp/qiming-migration-logs-1634224404.41/qiming-backend
Create log file for pod log-collector-74c865f9-bb8xg
Create log file for pod mig-controller-default-58ff75688c-g8rlj
Create log file for pod qiming-operator-94fcbbd57-6wg6c
Create log file for pod qiming-operator-velero-installer-78ddb79499-d8rbw
Create log file for pod ui-discovery-default-cdc8774bf-2rvpb
...
Collect configmap migration-cluster-config.yaml from namespace qiming-backend
Compress logs to /tmp/qiming-migration-logs-1634224404.41.tar

(app-root) sh-4.4$ ls -rlt /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 default root 15595520 Oct 14 15:06 /tmp/qiming-migration-logs-1634223960.63.tar

# copy log file out
[root@gyj-dev ~]# k -n qiming-migration exec -it log-collector-74c865f9-bb8xg -- sh ^C
[root@gyj-dev ~]# kubectl cp qiming-migration/log-collector-74c865f9-bb8xg:/tmp/qiming-migration-logs-1634224404.41.tar /tmp/qiming-migration-logs-1634224404.41.tar
...
[root@gyj-dev ~]# ls -rlt /tmp/qiming-migration-logs-1634224404.41.tar
-rw-r--r-- 1 root root 15626240 10月 14 23:14 /tmp/qiming-migration-logs-1634224404.41.tar
```


## collect velero logs on each k8s cluster

```bash

# install log collector for velero
[root@gyj-dev ~]# kubectl apply -f ./server-log-collector.yaml

# check log collector pod status
[root@gyj-dev ~]#  kubectl -n qiming-backend get pods
NAME                             READY   STATUS    RESTARTS   AGE
log-collector-76766456cc-hxnw5   1/1     Running   0          35m
minio-7496b65c8-zxmqr            1/1     Running   0          11h
restic-r94jv                     1/1     Running   0          11h
velero-75896549d-lvpct           1/1     Running   0          11h

# log in log collector pod 
[root@gyj-dev ~]# k -n qiming-backend exec -it log-collector-76766456cc-hxnw5 -- sh

# run collector command
(app-root) sh-4.4$ python /qiming/log-collector.py
Create logpath /tmp/qiming-migration-logs-1634223920.81/qiming-migration
Create logpath /tmp/qiming-migration-logs-1634223920.81/qiming-backend
Create log file for pod log-collector-74c865f9-bb8xg
Create log file for pod mig-controller-default-58ff75688c-g8rlj
Create log file for pod qiming-operator-94fcbbd57-6wg6c
Create log file for pod qiming-operator-velero-installer-78ddb79499-d8rbw
Create log file for pod ui-discovery-default-cdc8774bf-2rvpb
Create log file for pod log-collector-76766456cc-hxnw5
Create log file for pod minio-7496b65c8-zxmqr
...
Collect configmap migration-cluster-config.yaml from namespace qiming-migration
Collect configmap ui-configmap.yaml from namespace qiming-migration
Create logpath /tmp/qiming-migration-logs-1634223960.63/qiming-backend/configmap
Collect configmap migration-cluster-config.yaml from namespace qiming-backend
Compress logs to /tmp/qiming-migration-logs-1634223960.63.tar

(app-root) sh-4.4$ ls -rlt /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 default root 15595520 Oct 14 15:06 /tmp/qiming-migration-logs-1634223960.63.tar

# copy log file out
[root@gyj-dev ~]# kubectl cp qiming-backend/log-collector-76766456cc-hxnw5:/tmp/qiming-migration-logs-1634223960.63.tar /tmp/qiming-migration-logs-1634223960.63.tar
...
[root@gyj-dev ~]# ls -rlth /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 root root 15M 10月 14 23:11 /tmp/qiming-migration-logs-1634223960.63.tar

```