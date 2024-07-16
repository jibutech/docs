手动恢复总体流程

1. 通过restorejob恢复stage pod和PVC到一个临时namespace

2. （手动）对所有的etcd节点，将PVC的etcd snapshot数据通过scp传输至etcd节点的空闲目录下，例如：
```
cp <pv mount path>/snapshot.db /tmp/snapshot.db
```

3. （手动）停止api-server，这里展示使用kubeadm安装的为例（apiserver, controller-manager都是static pod在kube-system）：
```
# shutdown kubelet
systemctl stop kubelet

[root@palm ~]# ls /etc/kubernetes/manifests
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml

# 将kubenetes部署pod manifes移走
# 这里会停掉上面4个服务，etcd, apiserver, controller-manager, scheduler
mkdir /etc/kubernetes/manifests-bk
mv /etc/kubernetes/manifests/* /etc/kubernetes/manifests-bk/
```

4. （手动）移除所有 etcd 存储目录下数据，例如：
```
mv /var/lib/etcd /var/lib/etcd-old
```

5. （手动）在每个etcd节点执行etcdutl snapshot restore
```
# /etc/kubernetes/manifests/etcd.yaml 里面存有etcd name, 
# initial-cluster, initial-advertise-peer-urls等信息

etcdutl --data-dir "/var/lib/etcd/" \
  --name xxx \
  --initial-cluster "xxx=https://xxx:2380,etcd-1=https://xxx:2380,etcd-2=https://xxx:2380" \
  --initial-cluster-token etcd-cluster \
  --initial-advertise-peer-urls https://xxx:2380 \
  snapshot restore /tmp/snapshot.db
```

6. （手动）启动etcd，k8s服务，以kubeadm安装的k8s为例：
```
mv /etc/kubernetes/manifests-bk/* /etc/kubernetes/manifests/
systemctl start kubelet.service
```

7. （手动）检查 etcd 集群状态
```
ETCDCTL_API=3 etcdctl --cacert=/xxx/ca.pem --cert=/xxx/server.pem --key=/xxx/server-key.pem --endpoints=https://xxx:2379,https://xxx:2379,https://xxx:2379 endpoint health
```
8. （手动）检查集群状态