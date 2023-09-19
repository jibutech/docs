# 银数多云数据管家3.5版运维手册

## 目录结构

- [1. 配置作业报告](#1-配置作业报告)
- [2. 配置移动端实时告警](#2-配置移动端实时告警)
- [3. YS1000的自备份与恢复](#3-YS1000的自备份与恢复)
- [4. YS1000的自清理](#4-YS1000的自清理)
- [5. YS1000的日志收集与故障诊断](#5-YS1000的日志收集与故障诊断)
- [6. 参考文档](#6-参考文档)

## 1. 配置作业报告

在银数多云数据管家左侧菜单栏中选择“配置”进入配置页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-3.1.png)

目前支持配置邮件和微信报告。

在创建邮件报告中，填写正确smtp地址和port，以及发送人邮箱地址。

如邮箱无需验证，则关闭验证按钮；如需验证，打开验证按钮，并填写正确授权码或者用户名密码。

在创建微信报告中，填写正确微信地址。

填写发送时间（目前仅支持每天指定一个时间点），打开启用，点击“保存”，便可在该时间点收到每天的作业执行报告。



## 2. 配置移动端实时告警

从YS1000 v3.4.0 版本开始，支持helm安装时设置实时告警：

```
# example of alarm setting
# you need to setup a prometheus for ys1000 host cluster in advance, and add the host ip to your wechat list

alarm:
  enabled: true
  wechat:
    enabled: true
    corpID: "ww9435adfc497dffff"   # change to your company ID
    agentID: "'1000000'"    # change to your own ID
    toUser: "username"     # change to your own name
    apiSecret: "z2CJdkRuq14fCejAkEBaPt0w641QCD_teCatrfePE00"    # change to your wechatsecret
```



## 3. YS1000的自备份与恢复

-   自备份：

    从YS1000 v3.1版本开始，引入了新的自备份机制，用户只要在添加备份仓库时勾选“用于YS1000元数据备份/恢复”并创建，就默认开启自备份（默认自备份间隔时间5分钟，最多保留50份，可通过cr修改）

    ![](https://gitee.com/jibutech/tech-docs/raw/master/images/self-restore-s3-3.1.png)

-   自恢复：

    第一步，在需要恢复的集群上直接安装或者通过helmtool安装对应的ys1000版本。
    
    **【注意】新创建的YS1000所在命名空间必须与原集群一致；如果用于自备份/恢复的s3创建曾创建过备份/恢复或dr任务等，添加时必须与原来名字一致。 **
    
 
    - 通过helmtool安装并下载S3中保存的参数：
     
      1.安装helmtool

      ```
      docker pull registry.cn-shanghai.aliyuncs.com/jibutech/helm-tool:release-3.4.0
      ```

      2.下载对应版本和参数的helm chart到本地tmp目录
      
      ```
      docker run -v /tmp:/tmp registry.cn-shanghai.aliyuncs.com/jibutech/helm-tool:release-3.4.0 pull --access-key <default-s3-access-key> --secret-key <default-s3-secret-key>  --region <default-s3-region>  --bucket  <default-s3-bucket> --url <default-s3-url> --insecure=true -d /tmp --untar
      ```

      3.进入tmp目录安装YS1000

      ```
      helm install ys1000 ./ys1000/ -n ys1000 --create-namespace -f ./ys1000/my-values.yaml
      ```


    第二步，等待YS1000 中所有pod正常运行后，登录前端添加之前用于自备份的s3为数据备份仓库，并勾选“用于YS1000元数据备份/恢复”，点击创建，在弹框点击“是”

    ![](https://gitee.com/jibutech/tech-docs/raw/master/images/self-restore-yes-3.1.png)


## 4. YS1000的自清理

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

## 5. YS1000的日志收集与故障诊断

### 5.1 日志收集

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


### 5.2 常见问题

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
