# 银数多云数据管家3.1版使用说明书

## 目录结构

- [1. 银数多云数据管家典型用户场景介绍](#1-银数多云数据管家典型用户场景介绍)
    - [1.1 本地Kubernetes集群应用和数据的日常备份与恢复](#11-本地Kubernetes集群应用和数据的日常备份与恢复)
    - [1.2 在其它Kubernetes集群中恢复应用和数据](#12-在其它Kubernetes集群中恢复应用和数据)
    - [1.3 应用的跨云迁移](#13-应用的跨云迁移)
- [2. 运行环境与兼容性](#2-运行环境与兼容性)
- [3. 软件配置与授权](#3-软件配置与授权)
- [4. 配置集群与备份仓库](#4-配置集群与备份仓库)
    - [4.1 配置待保护Kubernetes集群](#41-配置待保护Kubernetes集群)
    - [4.2 配置数据备份仓库](#42-配置数据备份仓库)
    - [4.3 配置镜像备份仓库](#42-配置镜像备份仓库)
- [5. 备份设置](#5-备份设置)
    - [5.1 创建备份策略](#51-创建备份策略)
    - [5.2 创建备份计划](#52-创建备份计划)
    - [5.3 执行备份任务](#53-执行备份任务)
    - [5.4 查看备份作业](#54-查看备份作业)
    - [5.5 取消备份作业](#55-取消备份作业)
- [6. 应用管理](#6-应用管理)
    - [6.1 创建备份模版](#61-创建备份模版)
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
    - [9.2 执行增量迁移任务](#92-执行增量迁移任务)
    - [9.3 执行一键迁移任务](#93-执行一键迁移任务)
    - [9.4 查看迁移作业](#94-查看迁移作业)
    - [9.5 取消迁移作业](#95-取消迁移作业)
    - [9.6 修改相应应用信息](#96-修改相应应用信息)
    - [9.7 迁移中使用钩子程序](#97-迁移中使用钩子程序)
- [10. 钩子程序](#10-钩子程序)
    - [10.1 创建钩子程序](#101-创建钩子程序)
- [11. 容灾](#11-容灾)
    - [11.1 打开容灾功能](#111-打开容灾功能)
    - [11.2 创建容灾配置](#112-创建容灾配置)
    - [11.3 创建容灾实例](#113-创建容灾实例)
    - [11.4 容灾实例操作](#114-容灾实例操作)
    - [11.5 容灾集群操作](#115-容灾集群操作)
- [12. 配置作业报告](#12-配置作业报告)
- [13. 配置移动端实时告警](#13-配置移动端实时告警)
- [14. YS1000的自备份与恢复](#14-YS1000的自备份与恢复)
- [15. 产品限制](#15-产品限制)
- [16. 故障与诊断](#16-故障与诊断)
    - [16.1 日志收集](#161-日志收集)
    - [16.2 常见问题](#162-常见问题)


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

目前YS1000 3.0版支持管理的Kubernetes版本、对象存储以及主存储如下表所示：

| Kubernetes发行版   | S3对象存储                          | 云原生存储    | Snapshot CRD |
| ------------------ | ----------------------------------- | ------------- | ------------ |
| k8s社区版1.17-1.23 | S3兼容的对象存储（minio，qingstor, obs, cos） | NFS        | v1beta1/v1      |
|                    |                                     | Rook Ceph 1.4-1.8 | v1           |

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

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-cluster-2.10.0.png)


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


### 4.2 配置数据备份仓库

银数多云数据管家支持兼容S3接口的对象存储作为数据备份仓库。

第一步，从左侧菜单栏中选择“备份仓库”进入备份仓库列表页面，默认显示“数据备份仓库”页面：


![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3data-config-3.1.png)


第二步，点击“创建数据备份仓库”按钮进入数据备份仓库添加页面，“备份存储类型”统一选择S3：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-s3data-3.1.png)

选择备份仓库类型，输入数据备份仓库名称，S3存储空间名称，S3存储空间区域，S3访问域名，访问密钥及访问密钥口令

从YS1000 v2.10.0版本开始，支持归档功能，在创建备份仓库时默认不勾选，若勾选归档，则该仓库只能用于归档数据的存放。

从YS1000 v3.1.1版本开始，支持指定存储容量限制，以及指定是否用于YS1000元数据的备份/恢复（只能指定一个s3仓库作为自备份仓库）。

第三步，点击“提交”按钮，银数多云数据管家会自动对数据备份仓库进行访问测试，如果测试成功，在状态栏会显示“连接成功”。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3data-list-3.1.png)


### 4.3 配置镜像备份仓库

从YS1000 v3.1版本开始，支持添加镜像备份仓库用于备份应用的容器镜像。

第一步，从左侧菜单栏中选择“备份仓库”进入备份仓库列表页面，点击切换到“镜像备份仓库”页面：


![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3image-config-3.1.png)


第二步，点击“创建镜像备份仓库”按钮进入镜像备份仓库添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add-s3image-3.1.png)

输入仓库名称，以及正确的仓库信息：镜像服务地址、项目（组织）名称。

如果为公有仓库不需要用户名密码，则可以禁用tls验证；如果为私有仓库则需要正确填写用户信息，并开启tls验证。

第三步，点击“提交”按钮，查看镜像备份仓库列表信息：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/s3image-list-3.1.png)


## 5. 备份设置

从YS1000 v2.6.0版本开始，内置4个备份策略，用户也可以另外创建备份策略。

### 5.1 创建备份策略

从YS1000 3.1版本开始，备份资源类型的选择移至备份计划的创建页面。

在银数多云数据管家左侧菜单栏中选择“备份策略”进入备份策略页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/strategy-config-3.1.png)

第一步，点击“创建备份策略”按钮进入备份策略添加页面，从YS1000 2.10 版本开始，支持选择全量备份，之前版本创建的策略都是默认的永久增量。

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


### 5.2 创建备份计划

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

第三步，点击“下一步”选择备份策略，可以直接引用策略，也可以创建仅供该备份计划使用的自定义策略。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup3-2.10.png)

第四步，点击“下一步”选择数据库备份一致性保护（可选参数，目前支持mysql、mongodb、postgresql 和 redis）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup4-2.10.png)

第五步，点击“下一步”选择备份前、备份后、备份失败后执行的钩子程序（可选参数）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup5-2.10.png)

第六步，点击“下一步”选择高级配置，支持定期的备份数据检查、定期归档和备份的网络限速（可选参数）。

  - 带数据卷的备份可勾选数据校验：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-dataverify-2.10.png)

  - 带数据卷的备份可勾选定期归档，并且需要属于归档的s3仓库：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-archive-2.10.png)

  - 网络限速（仅对数据传输有效）：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-backup6-2.10.png)

点击完成后，系统会自动对备份任务进行验证，查看备份列表中备份计划的状态是否“已就绪”。

默认创建完按策略预定时间自动备份，也可点击操作列表中“停止自动运行”改成手动备份模式。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/schedule-backup-3.1.png)


### 5.3 执行备份任务

对于定时备份策略，系统会自动按照定时设定进行备份。同时，用户可以选择备份任务手动触发备份作业。

在备份页面中，选择对应备份计划的操作按钮，在操作中选择“备份”，再点击弹窗中“确定”按钮，备份作业即开始运行。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backup-start-3.1.png)


### 5.4 查看备份作业

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

备份成功后，任务状态右侧显示下载按钮，点击后可根据提示使用yscli下载备份任务的数据

切换到资源列表

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-2-3.1.png)

点击某个资源查看yaml

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-3-3.1.png)

切换到数据卷，备份成功后，快照信息右侧显示下载按钮，点击后可根据提示使用yscli下载数据卷的数据

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-detail-4-3.1.png)


### 5.5 取消备份作业

备份任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-cancel-1-3.1.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/backupjob-cancel-2-3.1.png)


## 6. 应用管理

从YS1000 v3.1版本开始，应用管理模块进一步增强，支持发现集群中所有命名空间，以及使用helm chart 安装的应用，如果是kubesphere集群，也可在前端查看所有workspace，并且支持前端创建自定义的备份模版。

在银数多云数据管家左侧菜单栏中选择“应用管理”进入应用发现页面，切换到命名空间，选择一个受管集群。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/namespace-page-3.1.png)

切换到应用发现，选择一个受管集群和应用类型：普通集群支持自动发现helm应用，如果是kubesphere集群还支持自动发现workspace。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/app-found-page-3.1.png)

切换到受管应用，目前版本只能展示出已经创建的受管应用。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/managed-app-page-3.1.png)

切换到备份模版，支持创建和查看自定义的备份模版。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/template-page-3.1.png)


### 6.1 创建备份模版

在备份模版页面点击“创建应用模版”按钮进入模版创建页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/create-template-3.1.png)

用户需要输入备份模版的名称和备份源集群，选择需要备份的标签，以及资源类型（命名空间资源或系统资源都可以配置包含或者不包含某类资源，可以具体到名称），并选择是否备份数据卷。


## 7. 恢复至本集群

从备份恢复应用至本集群一般在本地应用出现故障时使用（如命名空间被意外删除等），恢复往往无需进行应用资源本身相关的修改（如对外服务的域名和端口等）。

在成功的备份任务右侧点击“恢复”按钮进入恢复创建页面。


### 7.1 创建应用恢复计划

第一步，点击“恢复”按钮进入应用恢复任务添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore1-3.1.png)

输入应用恢复任务名称，并选择目标恢复集群。

可选参数：

1.沙箱恢复（从YS1000 v3.1 版本开始支持）

2.对目标命名空间进行修改（从YS1000 v2.10.0版本开始支持多命名空间的修改）。

第二步，点击下一步并选择恢复资源（注意包含数据卷的备份任务不能选择自定义资源的恢复）

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore2-3.1.png)

第三步，点击“下一步”选择恢复时间的策略，恢复优先级（数字越大优先级越高），以及是否在恢复前检查数据

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore3-3.1.png)

第四步，点击“下一步”选择应用恢复的目标存储类型

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore4-3.1.png)

可选参数：

1.“解除工作负载节点限制”：包含节点亲和性、节点标记和节点名字可分别移除。

2.”覆盖已有资源“：只有选择k8s资源时可以勾选。

3."使用已备份镜像"：只有备份任务包含镜像备份时选择有效，恢复时使用备份中的镜像源。

4.“修改工作负载镜像”：可以选择在目标集群中替换该恢复应用的镜像源或者镜像仓库。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/res-img-2.10.png)

第四步，点击“下一步”选择应用恢复前、恢复后、恢复失败后执行的钩子程序。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/restore5-2.10.png)

点击“完成”按钮后，恢复任务创建成功，系统会自动对恢复任务进行验证，并按照恢复策略指定的时间进行恢复。


### 7.2 执行应用恢复任务


如果在恢复策略中选择立即恢复，创建完成后在应用恢复页面，选择恢复任务列的链接，在相应恢复作业的列操作中选择“激活”，即可触发任务恢复作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/start-restore-3.1.png)


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

在银数多云数据管家左侧菜单栏中选择“跨集群应用迁移”进入应用迁移页面(有两个或以上受管集群，且备份仓库就绪才能创建)。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-config-3.1.png)


### 9.1 创建迁移计划

**【注意】在开始执行跨集群迁移任务前，要确认迁移的目标集群不存在资源冲突。**例如，如果迁移一个命名空间A到集群B，则要确认集群B不存在命名空间A。

 第一步，点击“创建迁移任务”按钮进入迁移任务添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-1-2.10.png)

用户需要输入迁移任务名称，选择源端集群和目标端集群，以及备份仓库。

第二步，点击“下一步”选择需要迁移的命名空间。

用户通过多选框选择需要迁移的命名空间，目前银数多云数据管家2.2以上版支持同时迁移多个命名空间。

用户可以通过“筛选”按钮对命名空间进行筛选，或者通过搜索栏搜索相关名称快速找到需要备份的命名空间。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-2-2.10.png)

第三步，点击“下一步”确认需要迁移的相关持久卷。

系统会自动选择出用户指定命名空间中使用到的持久卷，用户可以进行确认。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-3-2.10.png)

第四步，点击“下一步”选择持久卷的目标集群存储类型，银数多云数据管家2.5版本支持文件系统拷贝的方式进行跨集群迁移。用户需要选择目标集群上应用恢复时需要使用的StorageClass。目标端集群使用的StorageClass和源端集群使用的StorageClass可以不同。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-4-2.10.png)

其余可选参数请参照恢复计划中的高级配置选项。

第五步，点击“下一步”选择添加钩子程序（可选）。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-create-5-2.10.png)

最后点击完成。


### 9.2 执行增量迁移任务

从YS1000 2.7.0版本开始，支持增量迁移，即一个迁移计划创建后，可进行多次增量迁移，最后再进行一次一键迁移完成应用异地拉起
在应用迁移页面中，选择对应迁移计划的操作列，在操作中选择“增量迁移”，即可触发增量迁移作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-increment-3.1.png)


### 9.3 执行一键迁移任务

在应用迁移页面中，选择对应迁移计划的操作列，在操作中选择“一键迁移”，弹窗点击“迁移”，即可触发迁移作业。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-entire-3.1.png)

注意：迁移过程默认会停掉源集群中选定命名空间内的应用，以保证数据一致性。
用户可以选择迁移过程中是否停止源集群中的应用运行。例如对于支持宕机一致性（crash-consistency）的应用，如果不希望在迁移过程中停止源集群中的应用运行，用户可以勾选此选项。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-confirm-beta.png)


### 9.4 查看迁移作业

在迁移页面中，点击迁移任务栏的链接，即可查看迁移作业的执行情况，也可以通过任务监控页面浏览概况。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/mig-started-3.1.png)

### 9.5 取消迁移作业

迁移任务进行时，可点击右侧“取消”按钮进行取消

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-cancel-1-3.1.png)

取消成功后，状态更新

![](https://gitee.com/jibutech/tech-docs/raw/master/images/migrationjob-cancel-2-3.1.png)


### 9.6 修改相应应用信息

在目标端集群重新启动应用后，对于和源集群有冲突的资源需要进行相应的更改，然后才能在目标端完全恢复应用。如wordpress在目标端重启启动后，仍旧会绑定源端使用的域名，这时需要管理员将域名指向目标端集群IP，或者执行特定脚本来更改新域名。

### 9.7 迁移中使用钩子程序

钩子程序（Hook) 提供在备份，恢复以及迁移应用执行前后添加应用自定义逻辑的功能，满足不同应用的需求。
简单的自定义逻辑支持通过ansible playbook 脚本来实现，或者用户也可以根据应用需要开发自定义的钩子程序（容器镜像）。
钩子程序将会以 kubernetes 作业 (jobs.batch) 的形式在指定的备份，恢复以及迁移前后阶段执行。

常见的场景如下：

1. 应用数据一致性保证
   - 应用备份之前，通过自定义的 "prebackup" 钩子程序，调用应用的静默 (quiesce) 接口，暂停应用并将应用内存数据以及文件系统缓存刷入磁盘
   - 应用备份之后，通过自定义的 "postbackup" 钩子程序，调用应用的恢复 (unquiesce) 接口，恢复应用执行

2. 数据验证
   - 应用备份之后，通过自定义的 "postbackup" 钩子程序，验证数据完整性

3. 环境修改
   - 应用恢复到远程集群以后，需要对环境配置进行修改，比如通过 ingress 修改用户访问 web URL 地址

下面的例子以 wordpress 应用在跨集群迁移的场景下进行说明，wordpress 部署代码见 [wordpress example](https://github.com/jibutech/app-backup-hooks/tree/main/examples/wordpress)

- 迁移之前应用通过 https://wp-demo.jibudata.com:30165 访问 wordpress 
- 因业务需求，wordpress 需要迁移到远端目标集群，通过 https://blog.jibudata.com:30165 访问原 wordpress

1. 参考 [7.1 创建迁移任务](#71-创建迁移任务)，在创建迁移任务最后一步，如下图，点击 **添加钩子程序**

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_1.png)

2. 输入钩子程序名称，此处为 `postrestore-change-ingress-wp-url`

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_2.png)

3. 在 `Ansible playbook` 区域选择上次Ansible playbook 脚本或者直接将脚本内容复制到文本框中。 

此例的 ansible playbook 脚本为 [wp_migration_url_update.yaml](https://github.com/jibutech/app-backup-hooks/blob/main/examples/wordpress/wp_migration_url_update.yaml)。 

脚本根据wordpress 应用迁移要求，修改 mysql 数据库中的文章和站点的Web URL 地址，同时修改对外访问的ingress 地址。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_3.png)

4. 选择钩子程序执行的运行式环境并点击**创建** 按钮。

此例中，Ansible playbook 脚本在目标集群中执行，脚本示例采用在 wordpress mysql pod上直接运行命令进行数据库修改。

填入钩子程序作业运行所需的服务账户以及所在的命名空间，这里使用 `qiming-migration` （velero 安装的命名空间）以及 `velero` 服务账户来运行任务。
选择执行阶段为 "PostRestore".

**注意**: 

钩子程序运行操作需要确保指定的服务账户具有运行所需要的权限。

此例中 `velero` 服务账户具有 cluster admin 权限，因此可以通过 ansible 脚本登录到目标容器 (wordpress命名空间中的 mysql pod) 进行操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/2.2hook-4.png)


5. **创建**完成后，返回迁移任务向导页面，在钩子程序页面显示创建结果，之后点击 **完成** 按钮，参考 [7.2 执行迁移任务](#72-执行迁移任务) 执行迁移操作

![](https://gitee.com/jibutech/tech-docs/raw/master/images/add_hook_5.png)

6. 完成迁移之后，访问新的 web URL 地址，可观察到 wordpress 页面以更新为新的域名地址

迁移之前：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/wp_before_mig.png)

迁移之后

![](https://gitee.com/jibutech/tech-docs/raw/master/images/wp_after_mig.png)


## 10. 钩子程序

钩子程序(Hook) 提供在备份，恢复以及迁移应用执行前后添加应用自定义逻辑的功能，满足不同应用的需求。
从YS1000 v2.10.1版本开始，支持创建自定义钩子程序。

### 10.1 创建钩子程序

在银数多云数据管家左侧菜单栏中选择“钩子程序”进入页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-config-3.1.png)

点击“创建钩子程序”按钮进入钩子程序创建页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-create-2.10.png)

其中，必填参数为名称和执行阶段中的操作类型，至少选一个执行阶段，并添加远程程序命令或者自定义脚本，或者内置模版命令（3.1版本中仅支持备份前/恢复后的“pod-checker”、恢复前的“restore-checker”和恢复后/恢复失败后的“resource-cleaner”）。

可选参数：

1.“钩子程序镜像”：如果是不能连接外网的私有环境，则需要替换成私有部署的镜像。

2.“是否忽略执行错误”：默认不勾选，钩子程序执行出错后备份任务报错；如果勾选，则钩子程序执行出错后不影响备份任务执行成功。

3.“执行失败重试次数”：默认为空，钩子程序执行失败后将再重试3次；如果填入正整数，则失败重试次数会相应调整。

4.“执行超时时长”：默认为空，钩子程序执行时间不大于1800s，超过则钩子程序失败退出；如果填入正整数，则超时时间会相应调整。

5.“环境变量”：如果需要设置环境变量，传入钩子程序执行，可勾选此项，目前支持添加环境变量、configmap和secret的其中一种。

钩子程序创建完成后，可以点击右侧“空运行”，并填入运行阶段和运行环境，点击“执行”

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-dryrun-3.1.png)

再点击“查看日志”，检查其可执行性

![](https://gitee.com/jibutech/tech-docs/raw/master/images/hook-log-3.1.png)

## 11. 容灾

从YS1000 v3.0.0版本开始，持有容灾版许可证的用户，可以使用容灾功能（3.1版本开始支持nfs/ceph-mirror/backup-restore等数据同步方式）。

### 11.1 打开容灾功能

登录银数多云数据管家，并在右上角点击更多按钮，选择“许可证书”，查看您的订阅类型是否为容灾版。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/license-btn-3.0.png)

![](https://gitee.com/jibutech/tech-docs/raw/master/images/license-config-3.0.png)


确认容灾功能可用后，点击“高级功能设置”，并打开容灾功能，点击“确认”后，等待左侧导航栏出现“容灾”一栏。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-feature-3.0.png)


### 11.2 创建容灾配置

容灾功能应用的前提条件，需要连接容灾主集群，以及容灾从集群，两个集群的数据卷同步方式从3.1开始支持nfs/ceph-mirror/backup-restore等。

点击左侧导航栏“容灾”一栏，并点击“容灾配置策略”，点击“添加策略”/“创建容灾配置”按钮，并输入名称、仓库、主集群、从集群和数据卷同步类型“nfs”（如果应用没有数据卷可选择none），并输入正确的nfs服务器地址和路径，点击创建。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-config-create-3.0.png)

创建完成后，会显示在容灾配置列表，并等待容灾配置策略状态就绪。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-config-list-3.0.png)


### 11.3 创建容灾实例

点击左侧导航栏“容灾”一栏，并点击“容灾实例”，点击“添加实例”/"创建容灾实例"按钮，并输入名称、容灾配置、应用所在命名空间和应用筛选标签（可多选命名空间，标签为可选项，以空格或逗号分隔），点击创建。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-instance-create-3.0.png)

创建完成后，会显示在容灾实例列表，并等待第一次资源同步。此后资源同步的频率可以通过在备份策略中修改 dr-default 策略来更改，默认为每天0点进行同步。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-instance-list-3.0.png)

点击容灾实例右侧的“查看详情”按钮，详情页面会展示更多实例相关信息。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-instance-details-3.0.png)


### 11.4 容灾实例操作

在容灾详情页面中点击“实例操作”，查看容灾实例当前的状态以及可以进行的操作。

1. 资源同步完成后，如果从集群连接正常，则可以进行故障切换。也可以在故障切换之前，点击“触发资源同步”，手动进行一次资源同步后再做切换。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-operation-3.0.png)

2. 点击“故障切换”，并弹窗“确认”后，可以在下方“执行步骤”中查看切换进度；在切换过程中点击“取消”按钮，则此次切换操作将撤销；

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-failover-3.0.png)

若故障切换顺利完成，则应用将在从集群启动，此时主从集群关系对调，若从集群（原主集群）状态正常，则可以进行“回退”或者建立“反向同步”关系。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-failover-finish-3.0.png)

3. 点击“回退”，并弹窗“确认”后，则应用将回到原主集群继续运行；在回退过程中点击“取消”按钮，则此次回退操作将撤销；

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-restore-3.0.png)

4. 点击“反向同步”，并弹窗“确认”后，则建立新的资源同步关系（该过程较快）；并且自动进行一个新的资源同步，以便下一次的故障切换。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-reverse-3.0.png)

并且自动进行一个新的资源同步，以便下一次的故障切换。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-reverse-finish-3.0.png)

5. 如果在新的主集群上运行一段时间后，想要放回原主集群，可以再通过一次“故障切换”和“反向同步”返回到初始容灾状态（数据始终保持最新状态）。


### 11.5 容灾集群操作

在容灾详情页面中点击“实例操作”，选择应用主集群和容灾配置策略后，在同一个主集群运行，并且使用该容灾策略的容灾实例都会显示在右侧。再选择可执行的操作，点击“一键集群切换”按钮，所列实例就会一起执行该操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-cluster-switch-3.0.png)

可以返回到实例列表查看实例状态，或者点击“查看详情”页面查看具体信息。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-cluster-switch-list-3.0.png)


## 12. 配置作业报告

在银数多云数据管家左侧菜单栏中选择“配置”进入配置页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/config-3.1.png)

目前支持配置邮件和微信报告。

在创建邮件报告中，填写正确smtp地址和port，以及发送人邮箱地址。

如邮箱无需验证，则关闭验证按钮；如需验证，打开验证按钮，并填写正确授权码或者用户名密码。

在创建微信报告中，填写正确微信地址。

填写发送时间（目前仅支持每天指定一个时间点），打开启用，点击“保存”，便可在该时间点收到每天的作业执行报告。

邮件和微信相关参数配置可参考：

https://github.com/jibutech/docs/blob/main/email-configuration.md


## 13. 配置移动端实时告警

从YS1000 v2.8.4 版本开始，支持实时告警：

https://github.com/jibutech/docs/blob/main/alarm/alarm_config_guide.md


## 14. YS1000的自备份与恢复

-   自备份：

    从YS1000 v3.1版本开始，引入了新的自备份机制，用户只要在添加备份仓库时勾选“用于YS1000元数据备份/恢复”并创建，就默认开启自备份（默认自备份间隔时间5分钟，最多保留50份，可通过cr修改）

    ![](https://gitee.com/jibutech/tech-docs/raw/master/images/self-restore-s3-3.1.png)

-   自恢复：

    第一步，在需要恢复的集群上直接安装或者通过helmtool安装对应的ys1000版本。
    
    **【注意】新创建的YS1000所在命名空间必须与原集群一致；如果用于自备份/恢复的s3创建曾创建过备份/恢复或dr任务等，添加时必须与原来名字一致。 **
    
    YS1000安装与升级，参考

    https://github.com/jibutech/helm-charts/blob/main/README.md

    第二步，等待YS1000 中所有pod正常运行后，登录前端添加之前用于自备份的s3为数据备份仓库，并勾选“用于YS1000元数据备份/恢复”，点击创建，在弹框点击“是”

    ![](https://gitee.com/jibutech/tech-docs/raw/master/images/self-restore-yes-3.1.png)

    

## 15. 产品限制


-   PVC的类型暂时不支持Host Path方式

-   如果Pod自带有emptyDir类型的Volume，备份会出错

    解决方法：对要备份的Pod加一个annotation：

    `kubectl -n <namespace> annotate pod/<podname> backup.velero.io/backup-volumes-excludes=<volumename>`

-   取消备份、恢复、迁移任务后，不会对已经生成的资源进行回退，需要手动检查环境并删除，或者使用内置resource-cleaner钩子程序


## 16. 故障与诊断

### 16.1 日志收集

使用Helm安装YS1000的时可以指定YS1000的控制组件所使用的命名空间名字， 默认命令空间名为ys1000， YS1000的备份引擎安装在用户集群名为qiming-backend的命名空间内， 因此需要分别对控制组件和备份引擎进行日志收集。

## 

#### YS1000控制组件日志收集

1. 查询ys1000的serviceaccount， 更新server-log-collector.yaml文件中的serviceAccountName。

```
# server-log-collector.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: log-collector
  namespace: qiming-migration
  labels:
    app: log-collector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      serviceAccountName: qiming-operator
      containers:
      - name: log-collector
        image: registry.cn-shanghai.aliyuncs.com/jibudata/log-collector:v2.7.0
```

```
[root@gyj-dev ~]# kubectl -n ys1000 get sa
NAME                         SECRETS   AGE
default                      1         23d
qiming-operator-1634274895   1         10s

#  在server-log-collector.yaml搜索serviceAccountName并对应的"qiming-operator"替换为"qiming-operator-1634274895"

[root@gyj-dev ~]# grep serviceAccountName server-log-collector.yaml
      serviceAccountName: qiming-operator-1634274895
```

2. 部署 日志收集工具收集日志.

```
# 在ys1000命名空间内安装日志收集工具
[root@gyj-dev ~]# kubectl apply -f ./server-log-collector.yaml

# check log collector pod status
[root@gyj-dev ~]# kubectl -n ys1000 get pods
NAME                                                READY   STATUS    RESTARTS   AGE
log-collector-74c865f9-bb8xg                        1/1     Running   0          36m
cron-85b8fd5767-m2pfd                               1/1     Running   0          7d17h
mig-controller-default-784f64d4dc-fqrvz             1/1     Running   0          112m
mysql-0                                             1/1     Running   0          7d17h
ui-discovery-default-9d4ff6769-xwmjd                2/2     Running   0          5d21h
webserver-8d9b58776-4ck5b                           1/1     Running   0          5d21h

# 进入collector pod 
[root@gyj-dev ~]# k -n ys1000 exec -it log-collector-74c865f9-bb8xg -- sh

# 执行日志收集命令
(app-root) sh-4.4$ python /qiming/log-collector.py
(app-root) sh-4.4$ python /qiming/log-collector.py
Create logpath /tmp/qiming-migration-logs-1634224404.41/ys1000
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

# 将打包后的日志拷贝到指定目录
[root@gyj-dev ~]# k -n ys1000 exec -it log-collector-74c865f9-bb8xg -- sh ^C
[root@gyj-dev ~]# kubectl cp ys1000/log-collector-74c865f9-bb8xg:tmp/qiming-migration-logs-1634224404.41.tar /tmp/qiming-migration-logs-1634224404.41.tar
...
[root@gyj-dev ~]# ls -rlt /tmp/qiming-migration-logs-1634224404.41.tar
-rw-r--r-- 1 root root 15626240 10月 14 23:14 /tmp/qiming-migration-logs-1634224404.41.tar
```

## 

#### YS1000备份引擎日志收集

1. 下载文件client-log-collector.yaml

```
# client-log-collector.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: log-collector
  namespace: qiming-backend
  labels:
    app: log-collector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      serviceAccountName: velero
      containers:
      - name: log-collector
        image: registry.cn-shanghai.aliyuncs.com/jibudata/log-collector:v2.7.0
```

2. 部署日志收集工具并收集日志

```
# 安装日志收集工具
[root@gyj-dev ~]# kubectl apply -f ./client-log-collector.yaml

# 查看对应pod状态
[root@gyj-dev ~]#  kubectl -n qiming-backend get pods
NAME                                             READY   STATUS    RESTARTS   AGE
log-collector-76766456cc-hxnw5                   1/1     Running   0          35m
minio-7496b65c8-zxmqr                            1/1     Running   0          11h
amberapp-controller-manager-76d8fb4998-d8ndx     1/1     Running   0          12m
data-mover-controller-manager-5f6765fc9d-qmxwq   1/1     Running   0          12m
restic-hn5nw                                     1/1     Running   0          12m
velero-5586df6449-2w2nw                          1/1     Running   0          12m
velero-installer-76f989f69b-xzfm8                1/1     Running   0          13m

# 进入collector pod 
[root@gyj-dev ~]# k -n qiming-backend exec -it log-collector-76766456cc-hxnw5 -- sh

# 执行日志收集命令
(app-root) sh-4.4$ python /qiming/log-collector.py
Create logpath /tmp/qiming-migration-logs-1634223920.81/ys1000
Create logpath /tmp/qiming-migration-logs-1634223920.81/qiming-backend
Create log file for pod log-collector-74c865f9-bb8xg
Create log file for pod mig-controller-default-58ff75688c-g8rlj
Create log file for pod qiming-operator-94fcbbd57-6wg6c
Create log file for pod qiming-operator-velero-installer-78ddb79499-d8rbw
Create log file for pod ui-discovery-default-cdc8774bf-2rvpb
Create log file for pod log-collector-76766456cc-hxnw5
Create log file for pod minio-7496b65c8-zxmqr
...
Collect configmap migration-cluster-config.yaml from namespace ys1000
Collect configmap ui-configmap.yaml from namespace ys1000
Create logpath /tmp/qiming-migration-logs-1634223960.63/qiming-backend/configmap
Collect configmap migration-cluster-config.yaml from namespace qiming-backend
Compress logs to /tmp/qiming-migration-logs-1634223960.63.tar

(app-root) sh-4.4$ ls -rlt /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 default root 15595520 Oct 14 15:06 /tmp/qiming-migration-logs-1634223960.63.tar

# 将打包后的日志拷贝到指定目录
[root@gyj-dev ~]# kubectl cp qiming-backend/log-collector-76766456cc-hxnw5:tmp/qiming-migration-logs-1634223960.63.tar /tmp/qiming-migration-logs-1634223960.63.tar
...
[root@gyj-dev ~]# ls -rlth /tmp/qiming-migration-logs-1634223960.63.tar
-rw-r--r-- 1 root root 15M 10月 14 23:11 /tmp/qiming-migration-logs-1634223960.63.tar
```

### 16.2 常见问题


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
