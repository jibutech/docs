# 告警配置向导

YS1000 通过与 [ Prometheus ](https://github.com/prometheus/prometheus) 集成来实现监控与告警。YS1000 暴露业务metrics，用户通过配置 prometheus 告警规则根据metrics生成告警，然后通过 alertmanager 对告警进行分组并依照配置通过邮件、微信、webhook等方式发送。

# Prometheus 的安装

Prometheus 可以安装在 Kubernetes 集群中，也可以安装在集群外。推荐在集群中使用 [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) 管理 Prometheus 软件栈，常见容器云平台可以通过平台的软件商店安装，如果云平台不提供或者您的 Kubernetes 集群是自己搭建的，则可以通过 Helm 安装，安装步骤非常简单：
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install -n prometheus --create-namespace prometheus prometheus-community/kube-prometheus-stack
```

# YS1000 metrics target

YS1000 目前以 Kubernetes 服务暴露控制器的 metrics target，YS1000 安装以后会自动在安装的命名空间安装一个名为 mig-controller-biz-metrics 的服务，metrics 暴露在这个服务的 /metrics 路径，metrics 服务的CR上有标签```app.kubernetes.io/component: metrics```，配置时可以用这个标签筛选。

如果您使用 Prometheus Operator (kube-prometheus已集成) 的话就再简单不过了，您可以创建 ServiceMonitor 来让 Prometheus 抓取 YS1000 的 metrics。只需要将下面代码保存为 ys1000_servicemonitor.yaml，然后执行 ```kubectl apply -f ys1000_servicemonitor.yaml``` 即可（注意：如果 YS1000 的安装命名空间不是qiming-migration，请修改下面的 namespace 配置以匹配 YS1000 安装的命名空间）。

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    release: prometheus
  name: metrics-monitor
  namespace: qiming-migration  # please change to match the namespace that YS1000 is installed into.
spec:
  endpoints:
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    path: /metrics
    port: http
    scheme: http
    tlsConfig:
      insecureSkipVerify: true
  selector:
    matchLabels:
      app.kubernetes.io/component: metrics
```

如果没有使用 Prometheus Operator，则可以配置 scrape job 的 kubernetes_sd_configs 利用 Prometheus 自带的服务发现功能从API server自动发现metrics target。如果您的 Prometheus 不在 Kubernetes 集群中，则可以通过暴露此 mig-controller-metrics 的服务来让 Prometheus 抓取。

下面是利用 kubernetes_sd_configs 的 scrape job 配置一个示例。
```yaml
- job_name: some-job-name
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_label_app_kubernetes_io_component, __meta_kubernetes_service_labelpresent_app_kubernetes_io_component]
    separator: ;
    regex: (metrics);true
    replacement: $1
    action: keep
  - source_labels: [__meta_kubernetes_namespace]
    separator: ;
    regex: (.*)
    target_label: namespace
    replacement: $1
    action: replace
  kubernetes_sd_configs:
  - role: endpoints
    follow_redirects: true
    enable_http2: true
    namespaces:
      own_namespace: false
      names:
      - qiming-migration
```

# 配置 alert rules

## 预定义告警规则
我们预定义了一些告警规则来对一些常用的告警进行配置，包括“YS1000控制器下线”、“受管集群未就绪”、“数据备份仓库未就绪”、“备份计划未就绪”、“自备份计划未就绪”、“备份任务失败”、“自备份任务失败”、“备份任务验证错误”、“备份任务执行时间过长”。

要启用这些预定义的告警规则，如果您使用了 Prometheus Operator，只需要把我们的预规则定义安装为 PrometheusRule CR。安装方法同样很简单：只需要把下面代码保存为文件 prometheus_rules.yaml，然后使用命令 ```kubectl apply -f prometheus_rules.yaml``` 来安装（注意：如果 YS1000 的安装命名空间不是qiming-migration，请修改下面的 namespace 配置以匹配 YS1000 安装的命名空间）。

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    release: prometheus
  name: ys1000-alerts
  namespace: qiming-migration  # please change to match the namespace that YS1000 is installed into.
spec:
  groups:
  - name: migcontroller
    rules:
    - alert: MigControllerDown
      annotations:
        description: Migcontroller has disappeared from Prometheus target discovery.
        summary: Migcontroller disappeared from Prometheus target discovery.
        content: YS1000 controller disappeared from Prometheus target discovery, the YS1000 controller has probably crashed, please check immediately.
      expr: |-
        absent(up{job="mig-controller-biz-metrics"} == 1)
      for: 5m
      labels:
        severity: critical
        namespace: qiming-migration
    - alert: MigClusterNotReady
      annotations:
        description: Cluster {{$labels.migcluster}} is not ready, connected state is {{$labels.connected}}.
        summary: Cluster {{$labels.migcluster}} is not ready.
        content: 'Cluster {{$labels.migcluster}} is not ready, connected state is {{$labels.connected}}. errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      expr: |-
        migcluster_status{ready="false"}
      for: 5m
      labels:
        severity: warning
    - alert: MigStorageNotReady
      annotations:
        description: Storage {{$labels.migstorage}} is not ready.
        summary: Storage {{$labels.migstorage}} is not ready.
        content: 'Storage {{$labels.migstorage}} is not ready. errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      expr: |-
        migstorage_status{ready="false"}
      for: 5m
      labels:
        severity: warning
    - alert: SelfBackupPlanNotReady
      annotations:
        description: Self backup plan is not ready.
        summary: Self backup plan is not ready.
        content: 'Self backup plan is not ready. errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      expr: |-
        self_backupplan_status{ready="false"}
      for: 5m
      labels:
        severity: warning
    - alert: BackupPlanNotReady
      annotations:
        description: Backup plan {{$labels.backupplan}} is not ready.
        summary: Backup plan {{$labels.backupplan}} is not ready.
        content: 'Backup plan {{$labels.backupplan}} to backup namespace {{$labels.namespaces}} in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} is not ready. errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      expr: |-
        backupplan_status{ready="false"}
      for: 5m
      labels:
        severity: warning
    - alert: BackupJobFailed
      annotations:
        content: 'Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}} in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} failed: errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
        description: Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}} in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} failed.
        summary: Backup job {{$labels.backupjob}} failed.
      expr: |-
        backupjob_status{status="Failed"} > 0 UNLESS increase(backupjob_status{status="Failed"}[1m]) == 0
      labels:
        severity: critical
    - alert: SelfBackupJobFailed
      annotations:
        content: 'Self backup job {{$labels.backupjob}} using storage {{$labels.migstorage}} failed: errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
        description: Self backup job {{$labels.backupjob}} failed.
        summary: Self backup job {{$labels.backupjob}} failed.
      expr: |-
        self_backupjob_status{status="Failed"} > 0 UNLESS increase(self_backupjob_status{status="Failed"}[1m]) == 0
      labels:
        severity: critical
    - alert: BackupJobValidationError
      annotations:
        description: Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}} in cluster {{$labels.migcluster}} validation error.
        summary: Backup job {{$labels.backupjob}} validation error.
        content: 'Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}} in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} validation error: errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      expr: |-
        backupjob_status{status="ValidationError"}
      labels:
        severity: critical
    - alert: BackupJobLongRunning
      annotations:
        content:  'Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}} stay running for long time: errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
        description: Backup job {{$labels.backupjob}} in namespace {{$labels.namespaces}} stay running for long time.
        summary: 'Backup job {{$labels.backupjob}} stay running for long time: {{$value}} seconds.'
      expr: |-
        backupjob_running_time_seconds > 3600
      labels:
        severity: critical
```

如果您没有使用 Prometheus Operator，则需要把上面配置的规则保存为规则配置文件，保存到 Prometheus 的规则文件目录，具体可以参考[ Prometheus 配置文档 ](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file)

## 自定义告警规则

您也可以根据 YS1000 暴露的 metrics 自定义一些告警规则，各个 metric 的定义，包括 label 的定义以及 metric 值的定义请参见下文[Metrics 列表](#metrics-列表)一节。

# 配置 alertmanager

最后，我们来配置 alertmanager 来把告警发送出去。alertmanager 内置支持对接多种消息平台，包括邮件、企业微信、slack以及webhook等。我们也准备了一个示例 AlertmanagerConfig CR 提供给 Prometheus Operator 的用户直接安装用来把告警发送到企业微信：把下面代码保存为文件 alertmanager_config.yaml，然后用命令 ```kubectl apply -f alertmanager_config.yaml``` 即可完成配置（注意：请替换代码中尖括号(&lt;&gt;)内企业微信相关配置以匹配您的企业ID，agentID，secret，接收者账号等，具体请参考[企业微信文档](https://developer.work.weixin.qq.com/document/10013)。如果 YS1000 的安装命名空间不是qiming-migration，请修改下面的 namespace 配置以匹配 YS1000 安装的命名空间）。
```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: ys1000-alertmanager-config
  labels:
    release: prometheus
    alertmanagerConfig: ys1000
  namespace: qiming-migration  # please change to match the namespace that YS1000 is installed into.
spec:
  route:
    receiver: default-receiver
    routes:
      - receiver: 'webhook-and-wechat'
        repeatInterval: 5m
        matchers:
        - name: alertname
          matchType: =
          value: MigControllerDown
      - receiver: 'webhook-and-wechat'
        groupBy: ['migcluster']
        groupWait: 30s
        groupInterval: 5m
        repeatInterval: 30m
        matchers:
        - name: alertname
          matchType: =
          value: MigClusterNotReady
      - receiver: 'webhook-and-wechat'
        groupBy: ['migstorage']
        groupWait: 30s
        groupInterval: 5m
        repeatInterval: 30m
        matchers:
        - name: alertname
          matchType: =
          value: MigStorageNotReady
      - receiver: 'webhook-and-wechat'
        groupBy: ['backupplan']
        groupWait: 30s
        groupInterval: 5m
        repeatInterval: 30m
        matchers:
        - name: alertname
          matchType: =
          value: BackupPlanNotReady
      - receiver: 'webhook-and-wechat'
        groupBy: ['backupjob']
        groupWait: 30s
        groupInterval: 5m
        repeatInterval: 10m
        matchers:
        - name: alertname
          matchType: =
          value: BackupJobLongRunning
      - receiver: 'webhook-and-wechat'
        groupBy: ['backupjob']
        groupWait: 30s
        groupInterval: 5m
        repeatInterval: 10m
        matchers:
        - name: alertname
          matchType: =
          value: BackupJobValidationError
      - receiver: 'webhook-and-wechat'
        groupBy: ['backupjob']
        groupWait: 0s # please keep 0s
        groupInterval: 1m
        repeatInterval: 5m
        matchers:
        - name: alertname
          matchType: =
          value: SelfBackupJobFailed
      - receiver: 'webhook-and-wechat'
        groupBy: ['backupjob']
        groupWait: 0s # please keep 0s
        groupInterval: 1m
        repeatInterval: 5m
        matchers:
        - name: alertname
          matchType: =
          value: BackupJobFailed
  inhibitRules:
    - sourceMatch:
        - name: alertname
          matchType: =
          value: MigClusterNotReady
      targetMatch:
        - name: alertname
          matchType: =
          value: BackupPlanNotReady
      equal: ['migcluster']
    - sourceMatch:
        - name: alertname
          matchType: =
          value: MigStorageNotReady
      targetMatch:
        - name: alertname
          matchType: =
          value: BackupPlanNotReady
      equal: ['migstorage']
  receivers:
    - name: default-receiver
    - name: webhook-and-wechat
      wechatConfigs:
        - sendResolved: false
          corpID: '<请替换为企业微信的企业ID>'
          agentID: '<请替换为企业微信的agentID>'
          toUser: <请替换为告警接收人的企业微信的用户账号>
          apiSecret:
            name: 'wechat-apisecret'
            key: 'apiSecret'

---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: wechat-apisecret
  namespace: qiming-migration
data:
  apiSecret: <base64 编码后的 secret>

```

示例中各个告警的 repeatInterval 可以按需求调整，

# Metrics 列表

## migcluster_status 集群状态

类型: gauge

lables:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| migcluster | 集群名 | 
| ready | 是否就绪 | true, false
| connected | 是否已连接 | true, false
| errors | 错误代码
| warnings | 错误代码

values:

0: 已就绪

1: 已连接未就绪

2: 未就绪

## migstorage_status 存储仓库状态

类型: gauge

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| migstorage | 存储仓库名
| ready | 是否就绪 | true, false
| errors | 错误代码
| warnings | 错误代码

values:

0: 已就绪

1: 未就绪

## backupplan_status 备份计划状态

类型: gauge

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| backupplan | 备份计划名
| migcluster | 集群名
| namespaces | 备份命名空间
| repeat | 是否是定时备份 | true, false
| export | 是否导出 | true, false
| ready | 是否就绪 | true, false
| errors | 错误代码
| warnings | 错误代码

values: 

0: 已就绪

1: 未就绪

## self_backupplan_status 自备份计划状态

类型: gauge

labels: 同备份计划状态

values: 同备份计划状态

## backupjob_status 备份任务状态

类型: gauge

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| backupjob | 备份任务名
| backupplan | 备份计划名
| migcluster | 集群名
| migstorage | 存储仓库名
| namespaces | 备份命名空间
| pvs | 持久卷个数
| export | 是否导出 | true, false
| status | 状态 | Failed Succeeded Running Queued Canceled ValidationError Canceling Warning
| errors | 错误代码
| warnings | 错误代码

values: 始终是1

## self_backupjob_status 自备份任务状态

类型: gauge

labels: 同备份任务状态

values: 同备份任务状态

## backupjob_running_time_seconds 备份任务运行时间

类型: counter

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| backupjob | 备份任务名
| backupplan | 备份计划名
| migcluster | 集群名
| migstorage | 存储仓库名
| namespaces | 备份命名空间
| pvs | 持久卷个数
| export | 是否导出 | true, false

values: 备份任务已运行时间，单位为秒

## processed_backupjob 已处理的备份任务数

类型: counter

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| backupplan | 备份计划名
| status | 状态 | Failed Succeeded Canceled
| is_self_backup | 是否自备份 | true, false

values: 已处理的备份任务数

## backupjob_processing_duration_seconds

类型: gauge

labels: 同“已处理的备份任务数”

values: 备份任务处理时间

## backupjob_processing_duration_histogram

类型: histogram

labels: 同“已处理的备份任务数”

values: 备份任务处理时间

## backupjob_export_duration_seconds

类型: gauge

labels: 同“已处理的备份任务数”

values: 导出备份任务处理时间

## backupjob_export_duration_histogram

类型: histogram

labels: 同“已处理的备份任务数”

values: 导出备份任务处理时间

