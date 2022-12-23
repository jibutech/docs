# on cloudcore site

## install cloudcore

`helm install cloudcore ./cloudcore --namespace kubeedge --create-namespace -f ./cloudcore/values-ys1000-test.yaml`

note: create and check nodeport cloudcore service

## get cloudcore token

`keadm gettoken`

# on edge site

## configure dns to match the public internet ip of VM in /etc/hosts 

```
124.xx.xx.xx mycloudcore.ys1000.test.jibudata.com
```

## join k8s

```
keadm join --cloudcore-ipport=mycloudcore.ys1000.test.jibudata.com:30000 --edgenode-name=remote-node --token=ef68687f67... --certport=30002 
```

## check on k8s 

```
kubectl get nodes
NAME          STATUS   ROLES                  AGE    VERSION
remote-node   Ready    agent,edge             114m   v1.22.6-kubeedge-v1.12.1
...
```


# kubeedge migraiton test

1. backup kubeedge and edge-test namespace
2. create remote-node (Node resource) manually on target cluster
3. restore backup to target cluster (with preserveNodePorts set)
4. delete nodeport svc in source cluster
5. switch dns (mycloudcore.ys1000.test.jibudata.com) on edge-site to target public ip 
6. same edge node is migrated to target cluster and edge pod is migrate to target cluster 
