# 银数多云数据管家3.4版运维手册

## 目录结构

- [1. 配置作业报告](#1-配置作业报告)
- [2. 配置移动端实时告警](#2-配置移动端实时告警)
- [3. YS1000的自备份与恢复](#3-YS1000的自备份与恢复)
- [4. YS1000的自清理](#4-YS1000的自清理)
- [5. 参考文档](#5-参考文档)

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

## 5. 参考文档

1. YS1000安装与升级可参考

https://github.com/jibutech/helm-charts/blob/main/README.md


2. 邮件和微信相关参数配置可参考：

https://github.com/jibutech/docs/blob/main/email-configuration.md
