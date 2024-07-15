# 银数多云数据管家3.10版使用说明书

## 目录结构

- [1. 银数多云数据管家典型用户场景介绍](#1-银数多云数据管家典型用户场景介绍)
    - [1.1 本地Kubernetes集群应用和数据的日常备份与恢复](#11-本地Kubernetes集群应用和数据的日常备份与恢复)
    - [1.2 在其它Kubernetes集群中恢复应用和数据](#12-在其它Kubernetes集群中恢复应用和数据)
    - [1.3 应用的跨云迁移](#13-应用的跨云迁移)
- [2. 运行环境与兼容性](#2-运行环境与兼容性)
- [3. 软件配置与授权](#3-软件配置与授权)
- [4. 配置集群与备份仓库](#4-配置集群与备份仓库)
    - [4.1 配置待保护Kubernetes集群](#41-配置待保护Kubernetes集群)
    - [4.2 配置集群etcd备份](#42-配置集群etcd备份)
    - [4.3 配置数据备份仓库](#43-配置数据备份仓库)
    - [4.4 配置镜像备份仓库](#44-配置镜像备份仓库)
- [5. 应用管理](#5-应用管理)
    - [5.1 创建备份模版](#51-创建备份模版)
    - [5.2 创建集群实例](#52-创建集群实例)
- [6. 备份设置](#6-备份设置)
    - [6.1 创建备份策略](#61-创建备份策略)
    - [6.2 创建应用备份计划](#62-创建应用备份计划)
    - [6.3 创建集群备份计划](#63-创建集群备份计划)
    - [6.4 执行备份任务](#64-执行备份任务)
    - [6.5 查看备份作业](#65-查看备份作业)
    - [6.6 取消备份作业](#66-取消备份作业)
    - [6.7 删除备份作业](#67-删除备份作业)
- [7. 恢复至本集群](#7-恢复至本集群)
    - [7.1 创建应用恢复计划](#71-创建应用恢复计划)
    - [7.2 执行应用恢复任务](#72-执行应用恢复任务)
    - [7.3 查看应用恢复作业](#73-查看应用恢复作业)
    - [7.4 取消应用恢复作业](#74-取消应用恢复作业)
- [8. 恢复至其它集群](#8-恢复至其它集群)
    - [8.1 创建、执行、查看应用恢复任务](#81-创建、执行、查看应用恢复任务)
    - [8.2 修改相应应用信息](#82-修改相应应用信息)
- [9. 跨集群迁移](#9-跨集群迁移)
    - [9.1 创建迁移计划](#91-创建迁移计划)
    - [9.2 执行增量迁移和迁移测试](#92-执行增量迁移和迁移测试)
    - [9.3 执行一键迁移任务](#93-执行一键迁移任务)
    - [9.4 查看迁移作业](#94-查看迁移作业)
    - [9.5 取消迁移作业](#95-取消迁移作业)
- [10. 钩子程序](#10-钩子程序)
    - [10.1 创建钩子程序](#101-创建钩子程序)
- [11. 产品限制](#11-产品限制)


## 1. 银数多云数据管家典型用户场景介绍

银数多云数据管家（YS1000）是一款创新的云原生软件产品，为企业提供核心业务在多云架构下的备份恢复、应用迁移及容灾保护服务，它可以适用于多个云原生的业务场景中。

### 1.1 本地Kubernetes集群应用和数据的日常备份与恢复

通过银数多云数据管家，用户可以设置策略将容器应用和数据进行自动备份，当遇到事故时，可以对容器应用和数据进行一键恢复。

备份示意图：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-backup.png)

恢复示意图：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-local-restore.png)

### 1.2 在其它Kubernetes集群中恢复应用和数据

用户测试环境中，常常希望能使用开发集群或生产集群中的应用和数据副本进行测试，通过银数多云数据管家，用户可以利用开发集群或生产集群中应用和数据的备份，在测试集群中恢复出同样的环境进行测试。

当生产集群遇到软硬件故障或站点故障时，通过银数多云数据管家，用户可以利用生产集群中应用和数据的备份，在灾备站点集群来恢复应用，以提高业务连续性。

跨集群恢复示意图：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-remote-restore.png)

### 1.3 应用的跨云迁移

通过银数多云数据管家，用户可以一键将容器应用从一个Kubernetes集群迁移至另外一个完全异构的Kubernetes集群，如生产集群到灾备集群的切换，或不同厂商、架构的Kubernetes集群间的应用迁移等。

迁移示意图（一）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-migration1.png)

迁移示意图（二）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/use-case-migration2.png)

## 2. 运行环境与兼容性

推荐使用Chrome 71以上版本访问银数多云数据管家2.8版控制台。

目前YS1000 3.6版支持管理的Kubernetes版本、对象存储以及主存储如下表所示：

| Kubernetes发行版   | S3对象存储                              | 云原生存储    | Snapshot CRD |
| ------------------ | ------------------------------------- | ------------- | ------------ |
| k8s社区版1.17-1.26 | S3兼容的对象存储（minio,qingstor,obs,cos） | NFS        | v1beta1/v1      |
|                    |                                     | Rook Ceph 1.4-1.11 | v1           |

## 3. 软件配置与授权

|                  | 基础版 | 企业版       | 迁移版       |容灾版       |
| ---------------- | ------ | ------------ | ------------ |------------ |
| 集群节点数量     | 9    | 100000         | 100000      | 100000      |
| 备份与恢复 | 支持     | 支持       | 不支持          |支持          |
| 迁移      | 支持     | 支持       | 支持          |支持          |
| 容灾      | 不支持     | 不支持     | 不支持       |支持          |
| 售后支持         | 无     | 24*7远程支持 | 24*7远程支持 | 24*7远程支持 |
| 是否需要授权     | 否     | 是           | 是           |是           |

## 4. 配置集群与备份仓库

### 4.1 配置待保护Kubernetes集群

第一步，从左侧菜单栏中选择“集群信息”进入集群配置页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/cluster-config-3.1.png)

第二步，点击“添加集群”按钮进入集群添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-cluster-3.6.png)


“集群名称”请输入待保护Kubernetes集群名称。

从YS1000 v2.8.0版本开始，添加“发行版支持”选项，默认选择社区版k8s；并且添加集群不再使用url+token的方式，改为使用kubeconfig连接。

从YS1000 v2.10.0版本开始，YS1000部署所在宿主集群不显示于集群列表（仅用于自备份），如需使用该集群需要在集群页面添加。

可以在在“集群导入”中上传集群的kubeconfig文件，或直接粘贴kubeconfig内容（注意server地址替换成可访问的外网ip），例如：

```
cat ~/.kube/config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM2VENDQWRHZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRX
    server: https://111.222.333.444:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURGVENDQWYyZ0F3SUJBZ0lJZkozbGVpNU45VDB3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUK
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBc1pOaVloa2hLbTJiVjFEZnhZMUlXc21FTStYNncvem5zMEIwWkNX
```

第三步，点击“保存”按钮，YS1000会自动对待保护Kubernetes集群进行连接测试，如果连接成功并成功初始化，在状态栏会显示“连接成功”。

可选参数：
1.“替换镜像源”：
  如果需要修改集群的镜像源，请勾选“替换镜像源”，并填入需要替换的url（但是路径和tag需要与原image保持一致），如果原image试docker默认缩写地址，则不做替换。

2.“网速限制”：
  如果需要添加集群的网络限速，请勾选“网速限制”，并填入限速速度和限速时段（当前版本仅支持每天一个时间段的限速）。

3.“数据导入导出节点选择”：
  如果需要指定快照导出的工作节点，请勾选“数据导入导出节点选择”，并添加亲和性规则。

4.“资源标签”：
  如果需要对集群添加标签，请勾选“资源标签”，并添加标签键值对。

5.“任务并发配置”：
  如果需要增加任务的最大并发数量，或单节点导入导出的最大并发数量，可根据集群资源配置适当修改。 

6."仓库亲和性配置"：
  如果集群的备份或迁移需要指定带特定标签的仓库进行，则可配置对应的仓库标签。


### 4.2 配置集群etcd备份

从YS1000 v3.10版本开始，支持新版的K8S集群保护。需要在“应用管理”中创建集群实例，并在“集群备份”中创建集群实例的备份计划。

详情参考 (#52-创建集群实例) 和 (#63-创建集群备份计划)。


### 4.3 配置数据备份仓库

银数多云数据管家支持兼容S3接口的对象存储作为数据备份仓库。

第一步，从左侧菜单栏中选择“备份仓库”进入备份仓库列表页面，默认显示“数据备份仓库”页面：


![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3data-config-3.1.png)


第二步，点击“创建数据备份仓库”按钮进入数据备份仓库添加页面，“备份存储类型”统一选择S3：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-s3data-3.6.png)

选择备份仓库类型，输入数据备份仓库名称，S3存储空间名称，S3存储空间区域，S3访问域名，访问密钥及访问密钥口令

从YS1000 v2.10.0版本开始，支持归档功能，在创建备份仓库时默认不勾选，若勾选归档，则该仓库只能用于归档数据的存放。

从YS1000 v3.1.1版本开始，支持指定存储容量限制，以及指定是否用于YS1000元数据的备份/恢复（只能指定一个s3仓库作为自备份仓库）。

从YS1000 v3.6.1版本开始，支持设置仓库的资源标签，以便于更好的管理仓库。

第三步，点击“提交”按钮，银数多云数据管家会自动对数据备份仓库进行访问测试，如果测试成功，在状态栏会显示“连接成功”。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3data-list-3.1.png)


### 4.4 配置镜像备份仓库

从YS1000 v3.1版本开始，支持添加镜像备份仓库用于备份应用的容器镜像。

第一步，从左侧菜单栏中选择“备份仓库”进入备份仓库列表页面，点击切换到“镜像备份仓库”页面：


![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3image-config-3.1.png)


第二步，点击“创建镜像备份仓库”按钮进入镜像备份仓库添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-s3image-3.1.png)

输入仓库名称，以及正确的仓库信息：镜像服务地址、项目（组织）名称。

如果为公有仓库不需要用户名密码，则可以禁用tls验证；如果为私有仓库则需要正确填写用户信息，并开启tls验证。

第三步，点击“提交”按钮，查看镜像备份仓库列表信息：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3image-list-3.1.png)


## 5. 应用管理

从YS1000 v3.1版本开始，应用管理模块进一步增强，支持发现集群中所有命名空间，以及使用helm chart 安装的应用，如果是kubesphere集群，也可在前端查看所有workspace，并且支持前端创建自定义的备份模版。

在银数多云数据管家左侧菜单栏中选择“应用管理”进入应用发现页面，切换到命名空间，选择一个受管集群。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/namespace-page-3.10.png)

切换到应用发现，选择一个受管集群和应用类型：普通集群支持自动发现helm应用，如果是kubesphere集群还支持自动发现workspace。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/app-found-page-3.10.png)

切换到受管应用，目前版本只能展示出已经创建的受管应用。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/managed-app-page-3.10.png)

切换到备份模版，支持创建和查看自定义的备份模版。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/template-page-3.10.png)

切换到集群实例，支持创建和查看自定义的K8S集群保护实例。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/cluster-instance-page-3.10.png)


### 5.1 创建备份模版

在备份模版页面点击“创建应用模版”按钮进入模版创建页面。

用户需要输入备份模版的名称和备份源集群，并通过选择资源标签、应用资源或系统资源来定义模版。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-template-label-3.6.png)

- 选择资源标签时，若输入多个标签对，则需要满足所有标签的资源才会被选择

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-template-app-3.6.png)

- 选择应用资源时，可通过名称来选择包含或排除某些命名空间，或者通过标签的方式来选择应用；
  
  如果需要选择更细粒度的资源，可取消勾选资源选择”全部“，改为自定义包含或者不包含某些特定应用中的资源；

  如果需要过滤数据，可选择”指定数据卷“，从YS1000 v3.6 版本开始支持通过PVC名称或者NFS路径来指定数据卷。

  从YS1000 v3.9 版本开始支持备份未挂载的pvc数据卷的数据，在备份模版中，可以选择“是否备份未使用 pvc 数据卷的数据”中的“是”选项。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-template-cluster-3.9.png)

- 选择系统资源时，可指定包含或者不包含某些特定系统中的资源。


### 5.2 创建集群实例

在集群实例页面点击“创建集群实例”按钮进入集群实例创建页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/cluster-instance-create-3.10.png)

- 用户需要输入集群实例的名称，并选择备份集群（只能从已添加的受管集群中选择）；

- ETCD部署方式如果是在集群外的话选择“集群外”；

- Master节点Manifests路径和证书路径按照实际配置情况修改；

- 如勾选“备份Master节点其他目录”，则在输入框输入正确路径，多个路径可用逗号隔开；

- 如勾选“使用内置etcdctl命令”，则在输入框输入etcdctl命令所在的正确路径；

- 如果集群有其他环境变量需要配置，则填写正确的变量名称和值

点击保存后，集群实例列表更新。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/cluster-instance-list-3.10.png)


## 6. 备份设置

从YS1000 v2.6.0版本开始，内置4个备份策略，用户也可以另外创建备份策略。

### 6.1 创建备份策略

从YS1000 3.1版本开始，备份资源类型的选择移至备份计划的创建页面。

从YS1000 3.5版本开始，备份策略更名为灾备策略。

在银数多云数据管家左侧菜单栏中选择“灾备策略”进入策略页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-config-3.1.png)

第一步，点击“创建灾备策略”按钮进入备份策略添加页面，从YS1000 2.10 版本开始，支持选择全量备份，之前版本创建的策略都是默认的永久增量。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-entire-2.10.png)

创建一个默认类型资源的文件拷贝策略，指定每小时的15、45分开始备份。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-file-2.10.png)

注意：若选择默认备份，则恢复时可恢复全部资源，或者选择仅恢复部分资源；

     若选择仅备份PVC数据卷，则恢复时只能对应选择仅恢复PVC数据卷；

     若选择仅备份K8S资源，则恢复时只能对应选择部分K8S资源.

备份方法除了仍支持基于存储快照的备份和基于文件拷贝的备份，还新增了存储快照备份+后台数据导出的高级模式。

如需使用快照备份+后台数据导出的方式：备份方法选择“快照拷贝”，“是否导出快照”选择“是”，默认选择立即导出全部快照。

如果需要选择导出其中某些快照，设置“是否立即导出全部快照”为“否”，选择需要导出的快照，默认选择立即导出所选快照。

如果需要指定快照导出的执行时间，设置“是否立即导出所选快照”为“否”，指定快照导出的执行时间。

则所选择的快照将在备份执行完成后在指定时间自动导出到备份仓库。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-exp1-2.10.png)

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-create-exp2-2.10.png)


第二步，填写完成所需策略参数后点击“保存”，可查看策略页面新增的策略。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-list-3.1.png)


### 6.2 创建应用备份计划

在银数多云数据管家左侧菜单栏中选择“应用备份”进入备份页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-config-3.1.png)

第一步，点击“创建应用备份”按钮进入备份任务添加页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup1-3.1.png)

用户需要输入备份任务的名称和备份目标仓库。

从YS1000 v3.1版本开始，支持备份应用所使用的镜像，如果已经添加了镜像备份仓库，可勾选“是否备份镜像”并选择对应镜像备份仓库。

第二步，点击“下一步”选择需要备份的集群。
选择应用：选项有命名空间、备份模版、受管应用、helm，如果是qke集群可以自动发现工作空间，选择需要备份的具体应用。
并选择备份计划的优先级（数字越大优先级越高），以及备份资源（默认备份应用全部资源）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup2-2.10.png)

从YS1000 v3.1版本开始，若选择“仅备份pvc数据卷”，则支持备份pvc数据卷中指定的文件或者文件夹（mount目录的相对路径）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup2-3.1.png)

从YS1000 v3.9 版本开始支持备份未挂载的pvc数据卷的数据，可以选择“是否备份未使用 pvc 数据卷的数据”中的“是”选项。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup2-3.9.png)

第三步，点击“下一步”选择备份策略，可以直接引用策略，也可以创建仅供该备份计划使用的自定义策略。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup3-2.10.png)

第四步，点击“下一步”，从YS1000 v3.4版本开始，支持数据库逻辑备份功能。

在数据库高级备份选项中，选择数据库备份一致性保护（可选参数，目前支持mysql、mongodb、postgresql 和 redis）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup4-amberapp-3.4.png)

或者如果在第二步选择仅备份k8s资源，可以选择数据库逻辑备份（可选参数，目前仅postgresql version 13）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup4-dump-3.4.png)

输入对应数据的参数，并选择需要备份保护的数据库（多个数据库用逗号分隔）。

第五步，点击“下一步”选择备份前、备份后、备份失败后执行的钩子程序（可选参数）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup5-2.10.png)

第六步，点击“下一步”选择高级配置，支持定期的备份数据检查、定期归档和备份的网络限速（可选参数）。

  - 带数据卷的备份可勾选数据校验：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-dataverify-3.6.png)

  - 若开启归档beta功能，并且已添加专属归档的s3仓库，则带数据卷的备份可勾选定期归档：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-archive-2.10.png)

  - 网络限速（仅对数据传输有效）：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup6-2.10.png)

点击完成后，系统会自动对备份任务进行验证，查看备份列表中备份计划的状态是否“已就绪”。

默认创建完按策略预定时间自动备份，也可点击操作列表中“停止自动运行”改成手动备份模式。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/schedule-backup-3.1.png)


### 6.3 创建集群备份计划

从YS1000 v3.10版本开始，新增集群备份页面。在银数多云数据管家左侧菜单栏中选择“集群备份”进入备份页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/cluster-backup-config-3.10.png)

第一步，点击“创建集群备份”按钮进入备份任务添加页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-cluster-backup1-3.10.png)

用户需要输入备份任务的名称，选择备份的集群实例和备份仓库。

第二步，点击“下一步”选择备份方式，默认通过本地master节点备份，无需输入额外信息

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-cluster-backup2-3.10.png)

也可以选择通过其他服务器备份，需要输入正确的ip和端口号；并输入该服务登录的正确用户密码，或者ssh私钥；并按提示依次修改下列输入

- 连接ETCD的endpoints
- ETCD CA证书的路径
- ETCD client证书的路径
- ETCD client私钥的路径
- ETCD ctl的路径
- 快照文件临时保存目录

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-cluster-backup2-other1-3.10.png)

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-cluster-backup2-other2-3.10.png)

点击“连接测试”可以检查服务器连接是否正确。

第三步，点击“下一步”选择存储方式，默认使用PVC存储，需要选择PVC存储类和PVC大小

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-cluster-backup3-3.10.png)

第四步，点击“下一步”选择备份策略，注意此处只能选择文件拷贝方式的策略

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-cluster-backup4-3.10.png)

点击保存后，集群备份列表更新。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/cluster-backup-list-3.10.png)


### 6.4 执行备份任务

对于定时备份策略，系统会自动按照定时设定进行备份。同时，用户可以选择备份任务手动触发备份作业。

在备份页面中，选择对应备份计划的操作按钮，在操作中选择“备份”，再点击弹窗中“确定”按钮，备份作业即开始运行。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-start-3.1.png)


### 6.5 查看备份作业

在“应用备份”页面中，点击“备份任务”栏的链接，即可查看备份作业的执行情况。

备份任务成功后，可点击右侧“恢复”按钮进行恢复。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-complete-3.1.png)

在“任务监控”页面，可以查看所有备份、恢复和迁移任务，并支持任务列表下载。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/jobmonitor-page-3.1.png)

从YS1000 v2.7.0版本开始，新增任务详情页面，可以查看每个备份、恢复任务的详细情况。

详情页面有两个入口

1.点击备份任务右侧“详情”按钮

2.点击任务监控中的备份/恢复任务名称

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-1-3.1.png)

备份成功后，任务状态右侧显示下载按钮，点击后可根据提示使用yscli下载备份任务的数据，可以通过拷贝后端stub pod下载yscli命令，例如:

```
kubectl cp qiming-backend/stub-59d755df87-wr5ml:yscli ./yscli
```

切换到资源列表

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-2-3.1.png)

点击某个资源查看yaml

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-3-3.1.png)

切换到数据卷，备份成功后，快照信息右侧显示下载按钮，点击后可根据提示使用yscli下载数据卷的数据

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-4-3.1.png)


### 6.6 取消备份作业

备份任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-cancel-1-3.1.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-cancel-2-3.1.png)

### 6.7 删除备份作业

备份任务完成后，可点击右侧“删除”按钮进行删除

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-delete-1-3.9.png)



## 7. 恢复至本集群

从备份恢复应用至本集群一般在本地应用出现故障时使用（如命名空间被意外删除等），恢复往往无需进行应用资源本身相关的修改（如对外服务的域名和端口等）。

在成功的备份任务右侧点击“恢复”按钮进入恢复创建页面。


### 7.1 创建应用恢复计划

第一步，点击“恢复”按钮进入应用恢复任务添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore1-3.9.png)

输入应用恢复任务名称，并选择目标恢复集群。

可选参数：

1.沙箱恢复（从YS1000 v3.1 版本开始支持）

2.对目标命名空间进行修改（从YS1000 v2.10.0版本开始支持多命名空间的修改）。

第二步，点击下一步并选择恢复资源（注意仅备份pvc数据卷的备份任务不能选择自定义资源的恢复）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore2-3.9.png)

第三步，点击“下一步”选择恢复时间的策略，恢复优先级（数字越大优先级越高），以及是否在恢复前检查数据

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore3-3.9.png)

第四步，点击“下一步”选择应用恢复的目标存储类型

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore4-3.9.png)

可选参数：

1.“解除工作负载节点限制”：包含节点亲和性、节点标记和节点名字可分别移除。

2.”覆盖已有资源“：只有选择k8s资源时可以勾选。

3."使用已备份镜像"：只有备份任务包含镜像备份时可选，恢复时使用备份中的镜像源。

4.“修改工作负载镜像”：可以选择在目标集群中替换该恢复应用的镜像源或者镜像仓库。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/res-img-2.10.png)

5.”保留服务所使用的节点端口号“：勾选后恢复的服务若使用节点端口号，则端口号与原来的一致。

6.”修改Ingress“：修改源集群与目标集群的Ingress注解字段或IngressClass的映射，在目标集群上恢复时使用新的Ingress。

第五步，点击“下一步”选择应用恢复前、恢复后、恢复失败后执行的钩子程序。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore5-3.9.png)

从YS1000 v3.9.1 版本开始支持恢复时进行资源配置修改，点击“下一步”，勾选“是否需要额外对ConfigMap, Secret, Ingress, Service等其他任意资源以及数据卷进行修改”。（恢复任务暂时不支持数据卷的修改，迁移任务支持，其他选项两者一致）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore6-3.9.png)

选择修改 ConfigMap 或 Secret 时，只能修改data中的字段键值对，如：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore6-edit-configmap-3.9.png)

选择修改 Ingress 时，可以添加修改或删除注释，如：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore6-edit-ingress-3.9.png)

选择修改 Service 时，可以修改服务类型、服务端口的参数和服务的注释，如：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore6-edit-service-3.9.png)

最后点击“完成”按钮，恢复任务创建成功，系统会自动对恢复任务进行验证，并按照恢复策略指定的时间进行恢复。


### 7.2 执行应用恢复任务


如果在恢复策略中选择立即恢复，创建完成后在应用恢复页面，选择恢复计划的列操作中选择“恢复”，即可触发任务恢复作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/start-restore-3.6.png)


### 7.3 查看应用恢复作业

在应用恢复页面中，点击恢复任务栏的链接，即可查看恢复作业的执行情况，也可以通过任务监控页面浏览概况。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore-status-3.1.png)

从YS1000 v2.7.0版本开始，新增任务详情页面，可以查看每个备份、恢复任务的详细情况

详情页面有两个入口

1.点击恢复任务右侧“详情”按钮

2.点击任务监控中的备份/恢复任务名称

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restorejob-detail-3.1.png)


### 7.4 取消应用恢复作业

恢复任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restorejob-cancel-1-3.1.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restorejob-cancel-2-3.1.png)


## 8. 恢复至其它集群

从备份恢复应用至其它集群一般在远程容灾场景、开发/测试场景、数据重用场景中使用，恢复完成后可能需要进行应用资源相关的修改（如对外服务的域名和端口等）。

同恢复至本地集群一样，在备份成功的任务右侧选择“恢复”进入恢复页面。

### 8.1 创建、执行、查看应用恢复任务

对于创建、执行以及查看恢复任务的操作，可以参考7.1-7.3的内容，这里唯一的区别就是在选择恢复的集群时，选择的是跟备份集群不同的集群。

### 8.2 修改相应应用信息

在其它集群（如测试集群）恢复应用后，对于和原备份集群有冲突的资源需要进行相应的更改，然后才能在其它集群完全恢复应用。

如wordpress在新集群恢复后，仍旧会绑定备份集群中使用的域名，这时需要管理员将域名指向新集群IP，或者执行特定脚本来更改新域名。


## 9. 跨集群迁移

在银数多云数据管家左侧菜单栏中选择“应用迁移”进入应用迁移页面(有两个或以上受管集群，且备份仓库就绪才能创建)。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-config-3.5.png)


### 9.1 创建迁移计划

从YS1000 v3.5.0版本开始，使用新版迁移可以选择文件或者快照的数据拷贝方式，且拥有与备份恢复相同的应用选择方式、钩子程序选择方式和其他高级配置。

并且支持增量迁移提前执行迁移测试。

**【注意】如果迁移的目标集群已存在资源，则默认跳过该资源。**

从YS1000 v3.6.0版本开始，默认为简版迁移流程，只需要输入迁移任务名称，选择源端集群和目标端集群，即可提交。

系统自动匹配符合源集群亲和性的仓库，数据卷迁移方法也根据是否支持快照方式自动选择。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-simple-3.6.png)

也可以通过点击更多设置，进入原始迁移选项页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-1-3.9.png)

用户需要输入迁移任务名称，选择源端集群和目标端集群，以及中转存储。

第二步，点击“下一步”选择需要迁移的应用。

用户通过多选框选择需要迁移的命名空间、备份模版、受管应用或者helm应用等。

用户可以通过“筛选”按钮对命名空间进行筛选，或者通过搜索栏搜索相关名称快速找到需要备份的应用。

并且可以选择迁移全部资源和数据，也可以选择仅迁移数据或仅迁移k8s资源。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-2-3.9.png)

第三步，点击“下一步”选择数据卷的迁移方法，并且可以设置最多保留多少增量迁移。

从YS1000 3.6.0版本开始，支持自动检测复制方式，如果数据卷全部支持快照则优先使用快照方式。

如果迁移的目标集群与源集群的k8s版本差距较大，可以勾选“迁移时自动转换不兼容的K8S资源”，这样就会在迁移时自动转换不兼容的资源。

**【注意】共享存储迁移目前为beta版本，使用该方式的迁移需要在上一步选择仅迁移k8s资源，并额外添加内置钩子（请联系技术支持）。**

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-3-3.9.png)

第四步，点击“下一步”选择是否需要在任务执行各阶段添加钩子程序。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-4-3.9.png)

第五步，点击“下一步”选择是否需要修改目标集群的高级应用配置，如目标存储、节点限制、工作负载镜像等，也可以选择在每次增量迁移后执行数据校验。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-5-3.9.png)

从YS1000 v3.9.1 版本开始支持恢复时进行资源配置修改，点击“下一步”，勾选“是否需要额外对ConfigMap, Secret, Ingress, Service等其他任意资源以及数据卷进行修改”。（恢复任务暂时不支持数据卷的修改，迁移任务支持，其他选项两者一致）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-6-3.9.png)

选择修改数据卷时，可以将intree或hostpath的数据转换成pvc数据卷，如：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-6-edit-intree-3.9.png)

选择修改任意资源，则可以更加灵活的修改其他资源参数，如：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-6-edit-resource-3.9.png)

最后点击完成，可以在迁移计划右侧点击详情，查看迁移计划的具体内容。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migplan-detail-3.5.png)


### 9.2 执行增量迁移和迁移测试

从YS1000 2.7.0版本开始，支持增量迁移，即一个迁移计划创建后，可进行多次增量迁移，最后再进行一次一键迁移完成应用异地拉起。

在应用迁移页面中，选择对应迁移计划的操作列，在操作中选择“增量迁移”，并确认此操作，即可触发增量迁移作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-increment-3.5.png)

从YS1000 3.5.0版本开始，支持对已完成的增量迁移进行迁移测试，选择对应迁移计划的操作列，在操作中选择“创建迁移测试”，选择需要测试的增量迁移任务，可选是否进行沙箱测试，点击确认，即可触发迁移测试。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migration-test-create-3.5.png)

迁移测试旨在帮助用户提前掌握应用迁移的结果。

可以点击迁移计划的详情，查看迁移测试的进度，测试完成后如需进行一键迁移，需要先删除迁移测试任务。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migration-test-job-3.5.png)


### 9.3 执行一键迁移任务

在应用迁移页面中，选择对应迁移计划的操作列，在操作中选择“一键迁移”。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-confirm-3.5.png)

迁移过程默认不会停掉源集群中的应用，为保证数据一致性，用户可以再弹窗中勾选“迁移前在原集群关闭应用”，并可以再勾选“迁移后在原集群恢复应用”后点击迁移，即可触发迁移作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-entire-3.5.png)


### 9.4 查看迁移作业

在迁移页面中，点击迁移任务右侧的操作列，选择“详情”，即可查看迁移作业的执行情况，也可以通过任务监控页面浏览概况。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migjob-details-3.5.png)


### 9.5 取消迁移作业

迁移任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-cancel-1-3.5.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-cancel-2-3.5.png)


## 10. 钩子程序

钩子程序(Hook) 提供在备份，恢复以及迁移应用执行前后添加应用自定义逻辑的功能，满足不同应用的需求。
从YS1000 v2.10.1版本开始，支持创建自定义钩子程序。
从YS1000 v3.9版本开始，支持创建数据库备份一致性钩子程序。

### 10.1 创建钩子程序

在银数多云数据管家左侧菜单栏中选择“钩子程序”进入页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-config-3.9.png)

点击“创建钩子程序”按钮进入钩子程序创建页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-create-2.10.png)

其中，必填参数为名称和执行阶段中的操作类型，至少选一个执行阶段，并添加远程程序命令或者自定义脚本，或者内置模版命令（3.1版本中仅支持备份前/恢复后的“pod-checker”、恢复前的“restore-checker”和恢复后/恢复失败后的“resource-cleaner”）。

可选参数：

1.“钩子程序镜像”：如果是不能连接外网的私有环境，则需要替换成私有部署的镜像。

2.“是否忽略执行错误”：默认不勾选，钩子程序执行出错后备份任务报错；如果勾选，则钩子程序执行出错后不影响备份任务执行成功。

3.“执行失败重试次数”：默认为空，钩子程序执行失败后将再重试3次；如果填入正整数，则失败重试次数会相应调整。

4.“执行超时时长”：默认为空，钩子程序执行时间不大于1800s，超过则钩子程序失败退出；如果填入正整数，则超时时间会相应调整。

5.“环境变量”：如果需要设置环境变量，传入钩子程序执行，可勾选此项，目前支持添加环境变量、configmap和secret的其中一种。

点击“创建数据库一致性钩子程序”按钮进入数据库一致性钩子程序创建页面，参数同备份计划中的数据库备份一致性保护。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-database-create-3.9.png)

钩子程序创建完成后，可以点击右侧“空运行”，并填入运行阶段和运行环境，点击“执行”

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-dryrun-3.1.png)

再点击“查看日志”，检查其可执行性

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-log-3.1.png)

从YS1000 v3.5.0版本开始，支持在任务详情中查看钩子程序的执行日志。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-task-log-1-3.5.png)

点击查看，可以看到钩子程序的执行次数和每次的执行日志，也可以点击“保存”下载日志。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-task-log-2-3.5.png)
    

## 11. 产品限制

-   取消备份、恢复、迁移任务后，不会对已经生成的资源进行回退，需要手动检查环境并删除，或者使用内置resource-cleaner钩子程序
