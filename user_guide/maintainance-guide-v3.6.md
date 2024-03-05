# 银数多云数据管家3.6版运维手册

## 目录结构

- [1. 配置通知渠道](#1-配置通知渠道) 
- [2. 配置作业报告](#2-配置作业报告)
- [3. 配置移动端实时告警](#3-配置移动端实时告警)
- [4. YS1000的自备份与恢复](#4-YS1000的自备份与恢复)
- [5. YS1000的自清理](#5-YS1000的自清理)
- [6. YS1000的日志收集与故障诊断](#6-YS1000的日志收集与故障诊断)
- [7. 参考文档](#7-参考文档)

## 1. 配置通知渠道

在银数多云数据管家左侧菜单栏中选择“系统配置”进入配置页面，点击”通知渠道“一栏，目前支持配置邮件和微信两种渠道。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-mail-3.6.png)

- 在创建STMP邮件服务时，填写正确ip地址和port，以及发送人邮箱地址。

  如邮箱无需验证，则关闭验证按钮；如需验证，打开验证按钮，并填写正确授权码或者用户名密码。

  可点击”发送测试邮件“查看配置是否正确。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-wechat-3.6.png)

- 微信渠道目前支持两种方式：配置企业微信的群机器人webhook地址，或者企业微信的应用消息推送参数。

注意：使用应用消息推送的方式，需要将YS1000的宿主机器ip添加到企业微信允许发送的列表中。


## 2. 配置作业报告

在银数多云数据管家左侧菜单栏中选择“系统配置”进入配置页面，点击”通知配置“一栏。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-notify-setting-3.6.png)

打开启用，填写发送时间（目前仅支持每天指定一个时间点），点击“保存”，便可在该时间点生成最近24小时的作业执行报告（展示在驾驶舱中）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dashboard-report-3.6.png)

如果想通过其他渠道接收每日报告，也可以勾选需要的通知渠道。


## 3. 配置移动端实时告警

从YS1000 v3.6.0 版本开始，支持在GUI页面设置Prometheus实时告警。

在银数多云数据管家左侧菜单栏中选择“系统配置”进入配置页面，点击”告警配置“一栏，打开启用。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-alert-3.6.png)

### "服务监控"的标签配置

"服务监控"的标签配置将会被应用到 YS1000 自动安装的 `servicemonitors.monitoring.coreos.com` 资源上，因此这里配置的标签必须匹配 `prometheuses.monitoring.coreos.com` 资源的 spec 中的 serviceMonitorSelector。

例如：可以通过命令查询到 `prometheuses.monitoring.coreos.com` 资源的 spec 中的 serviceMonitorSelector：
```
# 如果是 Kubesphere 环境，prometheuses.monitoring.coreos.com 资源在命名空间 kubesphere-monitoring-system
# Prometheus Operator 安装的命名空间和 prometheuses.monitoring.coreos.com 资源的名字可能不同，请根据需要修改命令
[root@felix ~]# kubectl -n prometheus get prometheuses.monitoring.coreos.com prometheus-kube-prometheus-prometheus -o yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus-kube-prometheus-prometheus
  namespace: prometheus
  resourceVersion: "16348026"
  uid: 8b7f960c-9708-4b59-8c63-2ba0e0b5f928
spec:
  ...
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector:
    matchLabels:
      release: prometheus
  ...
```

所以需要在"服务监控"的标签配置输入框填入`release:prometheus`，并按回车。

### "配置Prometheus Rule"的标签配置
"配置Prometheus Rule"的标签配置将会被应用到 YS1000 自动安装的 `prometheusrules.monitoring.coreos.com` 资源上，因此这里配置的标签必须匹配 `prometheuses.monitoring.coreos.com` 资源的 spec 中的 ruleSelector。

例如：可以通过命令查询到 `prometheuses.monitoring.coreos.com` 资源的 spec 中的 ruleSelector：
```
# 如果是 Kubesphere 环境，prometheuses.monitoring.coreos.com 资源在命名空间 kubesphere-monitoring-system
# Prometheus Operator 安装的命名空间和 prometheuses.monitoring.coreos.com 资源的名字可能不同，请根据需要修改命令
[root@felix ~]# kubectl -n prometheus get prometheuses.monitoring.coreos.com prometheus-kube-prometheus-prometheus -o yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus-kube-prometheus-prometheus
  namespace: prometheus
  resourceVersion: "16348026"
  uid: 8b7f960c-9708-4b59-8c63-2ba0e0b5f928
spec:
  ...
  ruleNamespaceSelector: {}
  ruleSelector:
    matchLabels:
      prometheus: k8s
      role: alert-rules
  ...
```

所以需要在"配置警报管理器"的标签配置输入框填入`prometheus:k8s`，并按回车，然后再次在"配置警报管理器"的标签配置输入框填入`role:alert-rules`，并按回车。

### "配置警报管理器"的标签配置
"配置警报管理器"的标签配置将会被应用到 YS1000 自动安装的 `alertmanagerconfigs.monitoring.coreos.com` 资源上，因此这里配置的标签必须匹配 `alertmanagers.monitoring.coreos.com` 资源的 spec 中的 alertmanagerConfigSelector。

例如：可以通过命令查询到 `alertmanagers.monitoring.coreos.com` 资源的 spec 中的 alertmanagerConfigSelector：
```
# 如果是 Kubesphere 环境，`alertmanagerconfigs.monitoring.coreos.com` 资源在命名空间 kubesphere-monitoring-system
# Prometheus Operator 安装的命名空间和 alertmanagers.monitoring.coreos.com 资源的名字可能不同，请根据需要修改命令
[root@felix ~]# kubectl -n prometheus get alertmanagers.monitoring.coreos.com prometheus-kube-prometheus-alertmanager -o yaml
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  name: prometheus-kube-prometheus-alertmanager
  namespace: prometheus
spec:
  ...
  alertmanagerConfigNamespaceSelector: {}
  alertmanagerConfigSelector:
    matchLabels:
      release: prometheus
  ...
```

所以需要在"配置Prometheus Rule"的标签配置输入框填入`release:prometheus`，并按回车。


## 4. YS1000的自备份与恢复

-   自备份：

    从YS1000 v3.1版本开始，引入了新的自备份机制，用户只要在添加备份仓库时勾选“用于YS1000元数据备份/恢复”并创建，就默认开启自备份。

    ![](https://gitee.com/jibutech/tech-docs/raw/master/images/self-restore-s3-3.1.png)

    从YS1000 v3.6版本开始，可以在GUI”系统配置“-”自备份“中设置自备份的频率和保留个数：

    ![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-self-backup-3.6.png)


-   自恢复：

    第一步，在需要恢复的集群上直接安装或者通过helmtool安装对应的ys1000版本。
    
    **【注意】新创建的YS1000所在命名空间必须与原集群一致；如果用于自备份/恢复的s3创建曾创建过备份/恢复或dr任务等，添加时必须与原来名字一致。 **
    
 
    - 通过helmtool安装并下载S3中保存的参数：
     
      1.安装helmtool

      ```
      docker pull registry.cn-shanghai.aliyuncs.com/jibutech/helm-tool:release-3.6.2
      ```

      2.下载对应版本和参数的helm chart到本地tmp目录
      
      ```
      docker run -v /tmp:/tmp registry.cn-shanghai.aliyuncs.com/jibutech/helm-tool:release-3.6.2 pull --access-key <default-s3-access-key> --secret-key <default-s3-secret-key>  --region <default-s3-region>  --bucket  <default-s3-bucket> --url <default-s3-url> --insecure=true -d /tmp --untar
      ```

      3.进入tmp目录安装YS1000

      ```
      helm install ys1000 ./ys1000/ -n ys1000 --create-namespace -f ./ys1000/my-values.yaml
      ```

    第二步，等待YS1000 中所有pod正常运行后，登录前端添加之前用于自备份的s3为数据备份仓库，并勾选“用于YS1000元数据备份/恢复”，点击创建，在弹框点击“是”

    ![](https://gitee.com/jibutech/tech-docs/raw/master/images/self-restore-yes-3.1.png)

    **【注意】集群ETCD备份的参数单独保存在所保护的集群上，不在自备份范畴，自恢复后需要在YS1000 中重新配置。 **


## 5. YS1000的自清理

从YS1000 v3.4.0 版本开始，支持helm安装时设置自清理，则在 helm 卸载时将会删除所有 YS1000 相关资源：

```
migconfig:
  deletionPolicy:
    removeResources: true
```

或者从 stub pod 拷贝 yscli 命令，并在 helm 卸载前先执行自清理命令：

```
kubectl -n qiming-backend cp stub-c5b8c988f-wfpff:yscli ./yscli
chmod +x yscli
./yscli cleanup
```

## 6. YS1000的日志收集与故障诊断

### 6.1 日志收集

从YS1000 v3.5.0版本开始，支持使用yscli命令收集YS1000各组件的日志，包含所有cr资源

```
./yscli logs
I0908 22:55:41.722018   16159 request.go:690] Waited for 1.02353185s due to client-side throttling, not priority and fairness, request: GET:https://apiserver.cluster.local:6443/apis/agent.jibudata.com/v1alpha1?timeout=32s
2023-09-08T22:55:42.468+0800    INFO    Create log path /home/./ys1000-logs-2023-09-08T22:55:42+08:00
2023-09-08T22:55:43.843+0800    INFO    Create log path /home/./ys1000-logs-2023-09-08T22:55:42+08:00/crds
2023-09-08T22:55:43.920+0800    INFO    Collect custom resource definition apphooks.ys.jibudata.com
2023-09-08T22:55:43.958+0800    INFO    Collect custom resource definition archivejobs.ys.jibudata.com
...
2023-09-08T22:55:58.977+0800    INFO    Collect custom resource volumesnapshotlocations.velero.io meta-s3-sz-wk1-zh6xd from namespace qiming-backend
2023-09-08T22:55:58.977+0800    INFO    Collect custom resource volumesnapshotlocations.velero.io test-mphmr from namespace qiming-backend
2023-09-08T22:55:59.170+0800    INFO    Create log path /home/./ys1000-logs-2023-09-08T22:55:42+08:00/qiming-backend/configmaps
YS1000 logs are saved in directory  /home/./ys1000-logs-2023-09-08T22:55:42+08:00
```


### 6.2 常见问题

- 快照备份不工作  
    可能原因：快照的SnapshotClass没配好，比如没有加所需要的label。  
    解决方法：请参考3.4节的“配置快照”，把相应的配置做好。
- 快照恢复失败  
    可能原因：快照的SnapshotClass的`deletionPolicy`不是`Retain`。  
    解决方法：用`kubectl`查看相应的`volumesnapshotcontents` CR，看`deletionPolicy`是不是`Retain`，如果不是，请参考3.4节的“配置快照”，并修改SnapshotClass的yaml文件，重新apply。
- 备份/恢复/迁移任务卡在50%左右一直不动  
    可能原因：当前集群前面有备份/恢复一直完成不了，卡在Velero的队列中。  
    解决方法：查看是否有一个备份/恢复一直在进行，等前一个备份完成，或者超时（现在大约要4小时）后，当前这个任务就会开始。如果不想等，可以重启Velero的Pod来观察问题是否解决。
- 恢复很慢，花了比预期多很多的时间  
    可能原因：如果是异地恢复，可以去查看恢复的命名空间，看Pod是不是Image Pull失败，或者有什么异常情况，导致Pod起来太慢。 
- 部署到k8s集群时，velero不能正常运行，并且报`unexpected directory structure for host-pods volume ...`的错误    
    原因：这是由于k8s在安装时，没有使用标准的`/var/lib/kubelet/pods/`的目录格式。     
    解决方法：执行`mount -l | grep kubelet`，找到集群实际的Pod的路径，例如`/var/k8s/kubelet/pods/`，然后执行：
    ```bash
    kubectl patch ds/restic --namespace qiming-migration --type json -p  '[{"op":"replace","path":"/spec/template/spec/volumes/0/hostPath","value": { "path": "/var/k8s/kubelet/pods"}}]'
    ```
- 备份一个k8s版本 >= 1.21 集群上的应用，再恢复到一个 k8s版本 <= 1.20 的集群上后，应用中pod无法正常running的问题，参考：

  https://velero.cn/d/37-k8s-121-beta-feature-boundserviceaccounttokenvelerorestic


## 6. 参考文档

1. YS1000安装与升级可参考

https://github.com/jibutech/helm-charts/blob/main/README.md


2. 邮件和微信相关参数配置可参考：

https://github.com/jibutech/docs/blob/main/email-configuration.md


3. 完整的告警配置向导文档：

https://github.com/jibutech/docs/blob/main/alarm/alarm_config_guide.md
