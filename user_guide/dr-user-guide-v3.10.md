- [1. 容灾](#1-容灾)
    - [1.1 打开容灾功能](#11-打开容灾功能)
    - [1.2 添加容灾集群和数据仓库](#12-添加容灾集群和数据仓库)
    - [1.3 创建容灾配置](#13-创建容灾配置)
    - [1.4 创建容灾实例](#14-创建容灾实例)
    - [1.5 容灾实例操作](#15-容灾实例操作) 
    - [1.6 添加容灾群组](#16-添加容灾群组)
    - [1.7 容灾集群操作](#17-容灾集群操作)
    - [1.8 创建容灾演练](#18-创建容灾演练)
    - [1.9 创建容灾工作流](#19-创建容灾工作流)




# 1. 容灾

从YS1000 v3.10版本开始，持有容灾版许可证的用户，可以使用新的更灵活容灾功能。

## 1.1 打开容灾功能

登录银数多云数据管家，并在右上角点击更多按钮

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-bread.png)

选择“许可证书”，查看您的订阅类型是否为容灾版。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-license.png)

确认容灾功能可用后，点击“高级功能设置”，默认打开容灾功能，可根据数据同步类型的需要打开VolSync插件，点击“确认”。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-feature.png)


## 1.2 添加容灾集群和数据仓库

点击左侧导航栏“资源管理”一栏，并点击“集群信息”，点击“添加集群"按钮进入集群添加页面：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-cluster-add.png)

“集群名称”请输入待保护Kubernetes集群名称。

“发行版支持”选项，默认选择社区版k8s。

可以在“集群导入”中上传集群的kubeconfig文件，或直接粘贴kubeconfig内容（注意server地址替换成可访问的外网ip）

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

使用容灾功能，需要添加至少一对容灾的主从集群：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-cluster-list.png)

点击左侧导航栏“资源管理”一栏，并点击“备份仓库”，点击“创建数据备份仓库"按钮进入数据备份仓库添加页面，“备份存储类型”统一选择S3：

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-s3-add.png)

输入数据备份仓库名称，S3存储空间名称，S3存储空间区域，S3访问域名，访问密钥及访问密钥口令，点击“提交”按钮，银数多云数据管家会自动对数据备份仓库进行访问测试，如果测试成功，在状态栏会显示“连接成功”。


## 1.3 创建容灾配置

点击左侧导航栏“容灾配置”一栏，点击“创建容灾配置”按钮，并输入名称、仓库、主集群、从集群和数据卷同步类型，点击创建。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-config-add.png)

如果应用没有数据卷可选择“不同步数据”；如果应用的数据卷有外部同步方式，则选择如果容灾应用需要同步数据卷，则可根据实际应用配置情况选择数据卷同步类型。

创建完成后，会显示在容灾配置列表，并等待容灾配置策略状态就绪。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-config-list.png)

点击容灾配置名称，将跳转到配置的详情页面。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-config-detail.png)


## 1.4 创建容灾实例

点击左侧导航栏“容灾实例”一栏，点击“创建容灾实例”按钮，并输入名称、容灾配置、应用所在命名空间和应用筛选标签（可多选命名空间，标签为可选项，以空格或逗号分隔），点击创建。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-instance-add.png)

创建完成后，会显示在容灾实例列表，并等待第一次资源同步。此后资源/数据同步的频率可以在对应的备份策略中修改，默认为每天0点进行同步。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-instance-list.png)

点击容灾实例名称，将跳转到容灾实例的详情页面，会展示更多实例相关信息和操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-instance-detail.png)


## 1.5 容灾实例操作

在容灾详情页面中点击“实例操作”，查看容灾实例当前的状态以及可以进行的操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-instance-operation.png)

1. 资源/数据同步完成后，如果从集群连接正常，则可以进行切换/故障切换。如果主集群连接也正常，可以在切换之前，点击右上角“触发资源同步”，手动进行一次资源同步后再做切换。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-resource-sync.png)

2. 点击“切换”，并弹窗“确认”后，可以点击下方“上一次执行步骤”中查看任务进度；在切换过程中点击“取消”按钮，则此次切换操作将撤销；

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-failover-1.png)

若切换顺利完成，则应用将在从集群启动，此时主从集群关系对调，若从集群（原主集群）状态正常，则可以进行“回退”或者建立“反向同步”关系。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-failover-2.png)

3. 点击“回退”，并弹窗“确认”后，则应用将回到原主集群继续运行；在回退过程中点击“取消”按钮，则此次回退操作将撤销；

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-restore.png)

4. 点击“反向同步”，并弹窗“确认”后，则建立新的资源同步关系（该过程较快）；并且自动执行一个新的资源/数据同步，以便下一次的切换/故障切换。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-reverse.png)

并且自动进行一个新的资源同步，以便下一次的故障切换。

5. 如果在新的主集群上运行一段时间后，想要放回原主集群，可以再通过一次“切换”和“反向同步”返回到初始容灾状态（数据始终保持最新状态）。


## 1.6 添加容灾群组

点击左侧导航栏“容灾群组”一栏，点击“创建容灾群组”，并输入名称和容灾实例（数字越小代表优先级越高），点击创建。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-group-add.png)

创建完成后，会显示在容灾群组列表

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-group-list.png)

点击容灾群组名称，将跳转到容灾群组的详情页面，会展示更多容灾群组的相关信息和操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-group-detail.png)


## 1.7 容灾集群操作

点击左侧导航栏“集群操作”一栏，，选择应用主集群和容灾配置策略后，在同一个主集群运行，并且使用该容灾策略的容灾实例都会显示在右侧。再选择可执行的操作，点击“执行操作”按钮，并二次确认，所列实例就会一起执行该操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-cluster.png)


## 1.8 创建容灾演练

点击左侧导航栏“演练中心”一栏，，点击“创建容灾演练”，并输入名称、容灾实例、类型（目前仅支持沙箱）、演练集群（如果在从集群演练，需要制定到新的命名空间），点击创建。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-rehersal-add.png)

创建完成后，会显示在容灾演练列表

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-rehersal-list.png)

点击容灾演练名称，将跳转到容灾演练的详情页面，会展示更多容灾演练的相关信息和操作。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-rehersal-detail.png)

点击“开始演练”，执行一次容灾演练

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-rehersal-start.png)


## 1.9 创建容灾工作流

点击左侧导航栏“工作流”一栏，，点击“创建容灾演练”，并输入名称，可以添加自定义的钩子程序，或者添加内置控制指令，点击创建。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-workflow-add.png)

创建完成后，会显示在工作流列表

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-workflow-list.png)

返回容灾实例，选择需要添加工作流的容灾实例，点击右侧编辑按钮，点击右下角“更多设置”，勾选自定义工作流，并选择一个工作流点击确认和更新。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-workflow-instance.png)

点击容灾工作流名称，将跳转到工作流的详情页面，会展示更多工作流的相关信息，以及使用该工作流的容灾实例。

![](https://gitee.com/jibutech/tech-docs/raw/master/images/dr-3.10-workflow-detail.png)
