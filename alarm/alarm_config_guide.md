# 告警配置向导

YS1000 通过与 [ Prometheus ](https://github.com/prometheus/prometheus) 集成来实现监控与告警。YS1000 暴露业务 metrics，用户通过配置 prometheus 告警规则根据 metrics 生成告警，然后通过 alertmanager 对告警进行分组并依照配置通过邮件、微信、webhook 等方式发送。

我们推荐使用 Prometheus Operator 在集群中运行 Prometheus、Alertmanager 及 相关软件，Kubesphere 已经集成了 Prometheus Operator 在 kubesphere-monitoring-system 命名空间，华为 CCE 也可以插件的形式安装 Prometheus Operator。如果平台不提供安装选项，也可以使用 Helm 来安装，下面的示例将使用 kube-prometheus-stack 来通过 Helm 安装 Prometheus Operator。

# Prometheus Operator 介绍

Prometheus Operator 是一种基于 Kubernetes 的应用程序，用于管理 Prometheus 实例和相关的监控组件。它是由 CoreOS 开发的开源工具，旨在简化 Prometheus 和相关监控组件的部署和配置。

容器云平台通过使用 Prometheus Operator 简化在Kubernetes下部署和管理 Prmetheus 的复杂度，其通过 `prometheuses.monitoring.coreos.com` 资源声明式创建和管理Prometheus Server实例；其通过 `servicemonitors.monitoring.coreos.com` 资源和 `podmonitors.monitoring.coreos.com` 资源声明式的管理监控配置；其通过 `prometheusrules.monitoring.coreos.com` 资源声明式的管理告警规则；其通过 `alertmanagers.monitoring.coreos.com` 资源声明式创建和管理配置 Alertmanager 实例。

## Prometheus Operator 自定义资源

### `servicemonitors.monitoring.coreos.com`

`servicemonitors.monitoring.coreos.com` 资源声明可以被 prometheus 抓取的 kubernetes 服务，例如 YS1000 定义的`servicemonitors.monitoring.coreos.com`资源声明 ys1000 命名空间中匹配标签 `app.kubernetes.io/component: metrics` 的服务可以被 prometheus 抓取。
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  creationTimestamp: "2023-12-06T05:36:24Z"
  generation: 1
  labels:
    release: prometheus
  name: metrics-monitor
  namespace: ys1000
  resourceVersion: "16249814"
  uid: 4c97bd6a-7c65-41e9-8cc0-4d30cb5a049f
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

[`servicemonitors.monitoring.coreos.com` 资源的 API 文档](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.ServiceMonitor)

### `prometheusrules.monitoring.coreos.com`

`prometheusrules.monitoring.coreos.com` 资源声明一些告警规则，例如 YS1000 定义的 `prometheusrules.monitoring.coreos.com` 资源声明了一些预置的告警规则。
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  annotations:
    prometheus-operator-validated: "true"
  creationTimestamp: "2023-12-06T05:39:22Z"
  generation: 1
  labels:
    release: prometheus
  name: ys1000-alerts
  namespace: ys1000
  resourceVersion: "16250754"
  uid: d876766c-f551-4c8f-965b-96776a586ea8
spec:
  groups:
  - name: migcontroller
    rules:
    - alert: MigControllerAlive
      annotations:
        content: Migcontroller is alive.
        description: Migcontroller is alive.
        summary: Migcontroller is alive.
      expr: up{service="mig-controller-metrics"}
      for: 5m
      labels:
        namespace: ys1000
        severity: informational
    - alert: MigControllerDown
      annotations:
        content: YS1000 controller disappeared from Prometheus target discovery, the
          YS1000 controller has probably crashed, please check immediately.
        description: Migcontroller has disappeared from Prometheus target discovery.
        summary: Migcontroller disappeared from Prometheus target discovery.
      expr: absent(up{service="mig-controller-metrics"} == 1)
      for: 5m
      labels:
        namespace: ys1000
        severity: critical
    ...
```
[`prometheusrules.monitoring.coreos.com` 资源的 API 文档](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.PrometheusRule)

### `prometheuses.monitoring.coreos.com`
`prometheuses.monitoring.coreos.com` 资源声明一个 Prometheus 实例，在资源的 spec 中可以定义运行 Prometheus 实例的各种参数。

Prometheus 实例抓取的目标由 servicemonitors 和 podmonitors 等定义，但是一个 Prometheus 实例并不会抓取集群中所有 `servicemonitors.monitoring.coreos.com` 资源定义的服务，Prometheus 实例抓取的 service 由 `prometheuses.monitoring.coreos.com` 资源的 spec 中的 serviceMonitorNamespaceSelector 和 serviceMonitorSelector 配置。一个 `servicemonitors.monitoring.coreos.com` 资源，只有其命名空间的 labels 匹配 serviceMonitorNamespaceSelector，并且其自身的 labels 匹配 serviceMonitorSelector，其声明的 Kubernetes 服务才会被 Prometheues 实例抓取。serviceMonitorNamespaceSelector 配置为 null 表示只匹配 `prometheuses.monitoring.coreos.com` 资源所在命名空间中的 `servicemonitors.monitoring.coreos.com` 资源，serviceMonitorNamespaceSelector 配置为 `{}` 表示匹配集群中所有命名空间中的 `servicemonitors.monitoring.coreos.com` 资源。serviceMonitorSelector 配置为 null 表示不匹配任何 `servicemonitors.monitoring.coreos.com` 资源，serviceMonitorSelector 配置为 `{}` 表示匹配命名空间中所有的 `servicemonitors.monitoring.coreos.com` 资源。Prometheus Operator 收集满足这两个 selector 的 `servicemonitors.monitoring.coreos.com` 资源，生成此 Prometheus 实例的抓取目标列表。

例如，对于上面的名为 "metrics-monitor" 的 `servicemonitors.monitoring.coreos.com` 资源，如果 `prometheuses.monitoring.coreos.com` 资源的 spec 中 serviceMonitorNamespaceSelector 和 serviceMonitorSelector 被配置为：
```yaml
serviceMonitorNamespaceSelector: {}
serviceMonitorSelector:
  matchLabels:
    prometheus: k8s
```
因为 "metrics-monitor" 的 labels 不能匹配 serviceMonitorSelector，则 Prometheus 实例的抓取目标列表不会包含 "metrics-monitor" 中声明的 Kubernetes 服务，这些服务所暴露的 metrics 也不会进入 Prometheus 的时序数据库，进而也无法通过这些 metrics 生成告警。如果需要这些服务被抓取，我们需要配置 "metrics-monitor" 的 labels 为 "prometheus:k8s"。

与此类似，Prometheus 实例生成告警的规则由 `prometheusrules.monitoring.coreos.com` 资源定义，Prometheus 实例的规则列表由 `prometheuses.monitoring.coreos.com` 资源的 spec 中的 ruleNamespaceSelector 和 ruleSelector 配置。一个 `prometheusrules.monitoring.coreos.com` 资源，只有其命名空间的 labels 匹配 ruleNamespaceSelector，并且其自身的 labels 匹配 ruleSelector，其声明的告警规则才会被 Prometheus 实例应用来生成告警。

例如，对于上面的名为 "ys1000-alerts" 的 `prometheusrules.monitoring.coreos.com` 资源，如果 `prometheuses.monitoring.coreos.com` 资源的 spec 中 ruleNamespaceSelector 和 ruleSelector 被配置为：
```yaml
ruleNamespaceSelector: {}
ruleSelector:
  matchLabels:
    prometheus: k8s
    role: alert-rules
```
因为 "ys1000-alerts" 的 labels 不能匹配 ruleSelector，则 "ys1000-alerts" 中的告警规则不会被应用，其中定义的告警不会被触发。如果需要这些规则生效，需要配置 "ys1000-alerts" 的 labels 为：
```yaml
  labels:
    prometheus: k8s
    role: alert-rules
```


[`prometheuses.monitoring.coreos.com` 资源的 API 文档](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.Prometheus)

### `alertmanagerconfigs.monitoring.coreos.com`

`alertmanagerconfigs.monitoring.coreos.com` 声明一些对AlertManager的配置，例如 YS1000 定义的 `alertmanagerconfigs.monitoring.coreos.com` 资源声明了一些告警的发送配置。
```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  creationTimestamp: "2023-12-06T05:39:22Z"
  generation: 1
  labels:
    alertmanagerConfig: ys1000
    release: prometheus
  name: ys1000-alertmanager-config
  namespace: ys1000
  resourceVersion: "16250755"
  uid: 4e432b6f-6009-40d7-919c-9c40c56413ca
spec:
  inhibitRules:
  - equal:
    - migcluster
    sourceMatch:
    - name: alertname
      value: MigClusterNotReady
    targetMatch:
    - name: alertname
      value: BackupPlanNotReady
  - equal:
    - migstorage
    sourceMatch:
    - name: alertname
      value: MigStorageNotReady
    targetMatch:
    - name: alertname
      value: BackupPlanNotReady
  receivers:
  - name: default-receiver
  - name: wechat-webhook-receiver
    wechatConfigs:
    - agentID: "1000003"
      apiSecret:
        key: wechat_corp_secret
        name: system-setting
      corpID: wwxxx3333388888888
      message: "{{- if gt (len .Alerts.Firing) 0 -}}\n{{- range $index, $alert :=
        .Alerts -}}\n==========异常告警==========\n告警类型: {{ $alert.Labels.alertname }}\n告警级别:
        {{ $alert.Labels.severity }}\n告警摘要: {{$alert.Annotations.summary}}\n告警描述:
        {{ $alert.Annotations.description}}\n告警详情: {{ $alert.Annotations.content }}\n故障时间:
        {{ ($alert.StartsAt.Add 28800e9).Format \"2006-01-02 15:04:05\" }}\nSource:
        {{ $alert.GeneratorURL }}\n============END============\n{{- end }}\n{{- end
        }}\nAlertmanager URL: {{ template \"__alertmanagerURL\" . }} "
      sendResolved: false
      toUser: ""
  route:
    receiver: default-receiver
    routes:
    - matchers:
      - name: alertname
        value: MigControllerAlive
      receiver: wechat-webhook-receiver
      repeatInterval: 24h
    ...
    - matchers:
      - name: alertname
        value: MigControllerDown
      receiver: wechat-webhook-receiver
      repeatInterval: 1h
```

### `alertmanagers.monitoring.coreos.com`

`alertmanagers.monitoring.coreos.com` 资源声明一个 AlertManager 实例，在资源的 spec 中可以定义运行 AlertManager 实例的各种参数。

与 `prometheuses.monitoring.coreos.com` 资源类似，`alertmanagers.monitoring.coreos.com` 资源的 spec 中的 alertmanagerConfigNamespaceSelector 和 alertmanagerConfigSelector 定义此 AlertManager 实例使用的 `alertmanagerconfigs.monitoring.coreos.com` 资源。Prometheus Operator 收集满足这两个 selector 的 `alertmanagerconfigs.monitoring.coreos.com` 资源，生成 AlertManager 实例的配置信息并运行 AlertManager 实例。

# Prometheus Operator 的安装

下面的命令将在 prometheus 命名空间安装 Prometheus Operator:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install -n prometheus --create-namespace prometheus prometheus-community/kube-prometheus-stack
```

# YS1000 中启用告警

安装 Prometheus Operator 后，可以在 YS1000 Web 界面的“系统设置”页面的“告警配置”标签页启用告警，YS1000 将会在 YS1000 安装的命名空间中自动安装 Prometheus Operator 相关的 CR。

## "服务监控"的标签配置

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

## "配置Prometheus Rule"的标签配置
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

## "配置警报管理器"的标签配置
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

## 配置通知方式

根据需要选择警报管理器 Webhook 通知或者微信应用消息推送。
如果选择警报管理器 Webhook 通知，需要配置 警报管理器Webhook地址。如果选择微信应用消息推送，需要在"通知渠道"标签页中的微信标签页配置"应用消息推送"。

## 保存

点击"保存"按钮，保存成功后稍等片刻，YS1000 会在 YS1000 安装的命名空间自动安装 `servicemonitors.monitoring.coreos.com`、`prometheusrules.monitoring.coreos.com` 和 `alertmanagerconfigs.monitoring.coreos.com`等资源。至此 YS1000 中的告警配置就完成了。

# 不使用 Prometheus Operator 的告警配置

如果不使用 Prometheus Operator 来管理 Prometheus 和 Alertmanager，则不需要在 YS1000 Web 界面的“系统设置”页面的“告警配置”标签页启用告警，YS1000 则不会自动安装 Prometheus Operator 相关的 CR。管理员需要修改 Prometheus 和 Alertmanager 的配置文件来实现对 YS1000 的监控和告警。

## YS1000 metrics target

YS1000 目前以 Kubernetes 服务暴露控制器的 metrics target，YS1000 安装以后会自动在安装的命名空间安装一个名为 mig-controller-metrics 的服务，metrics 暴露在这个服务的 /metrics 路径，metrics 服务的CR上有标签 `app.kubernetes.io/component: metrics`，配置时可以用这个标签筛选。

> 注意！在YS1000 2.9之前版本(2.8.2)中 metrics 服务的名字为 mig-controller-biz-metrics，如果您从2.8.2升级到2.9及以后的版本，请删除这个服务，并更新您的告警规则配置中对这个名字的引用为 mig-controller-metrics。

如果没有使用 Prometheus Operator，则可以配置 scrape job 的 kubernetes_sd_configs 利用 Prometheus 自带的服务发现功能从 API server 自动发现 metrics target。如果您的 Prometheus 不在 Kubernetes 集群中，则可以通过暴露此 mig-controller-metrics 的服务来让 Prometheus 抓取。

下面是利用 kubernetes_sd_configs 的 scrape job 配置一个示例（注意：请替换代码中尖括号(&lt;&gt;)内的 ys1000 安装的命名空间)。

```yaml
- job_name: some-job-name
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  relabel_configs:
    - source_labels:
        [
          __meta_kubernetes_service_label_app_kubernetes_io_component,
          __meta_kubernetes_service_labelpresent_app_kubernetes_io_component,
        ]
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
          - <ys1000 安装的命名空间>
```

## 配置告警规则

### 预定义告警规则
我们预定义了一些告警规则来对一些常用的告警进行配置，包括“YS1000控制器下线”、“受管集群未就绪”、“数据备份仓库未就绪”、“备份计划未就绪”、“自备份计划未就绪”、“备份任务失败”、“自备份任务失败”、“备份任务验证错误”、“备份任务执行时间过长”。

把下面的规则配置保存为规则配置文件，保存到 Prometheus 的规则文件目录，具体请参考[ Prometheus 配置文档 ](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file)

```yaml
groups:
- name: migcontroller
  rules:
  - alert: MigControllerAlive
    annotations:
      content: Migcontroller is alive.
      description: Migcontroller is alive.
      summary: Migcontroller is alive.
    expr: up{service="mig-controller-metrics"}
    for: 5m
    labels:
      namespace: ys1000
      severity: informational
  - alert: MigControllerDown
    annotations:
      content: YS1000 controller disappeared from Prometheus target discovery, the
        YS1000 controller has probably crashed, please check immediately.
      description: Migcontroller has disappeared from Prometheus target discovery.
      summary: Migcontroller disappeared from Prometheus target discovery.
    expr: absent(up{service="mig-controller-metrics"} == 1)
    for: 5m
    labels:
      namespace: ys1000
      severity: critical
  - alert: MigClusterNotReady
    annotations:
      content: 'Cluster {{$labels.migcluster}} is not ready, connected state is {{$labels.connected}}.
        errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      description: Cluster {{$labels.migcluster}} is not ready, connected state is
        {{$labels.connected}}.
      summary: Cluster {{$labels.migcluster}} is not ready.
    expr: migcluster_status{ready="false"}
    for: 5m
    labels:
      severity: critical
  - alert: MigStorageNotReady
    annotations:
      content: 'Storage {{$labels.migstorage}} is not ready. errors: {{$labels.errors}}.
        warnings: {{$labels.warnings}}.'
      description: Storage {{$labels.migstorage}} is not ready.
      summary: Storage {{$labels.migstorage}} is not ready.
    expr: migstorage_status{ready="false"}
    for: 5m
    labels:
      severity: critical
  - alert: MigStorageUsageOverThreshold
    annotations:
      content: The used capacity of storage {{$labels.migstorage}} is over threshold.
      description: The used capacity of storage {{$labels.migstorage}} is over threshold.
      summary: The used capacity of storage {{$labels.migstorage}} is over threshold.
    expr: (migstorage_used_bytes  / on(migstorage, namespace) migstorage_quota unless
      on(migstorage, namespace) (migstorage_quota == 0.0)) > 0.8
    labels:
      severity: warning
  - alert: BackupPlanNotReady
    annotations:
      content: 'Backup plan {{$labels.backupplan}} to backup namespace {{$labels.namespaces}}
        in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} is
        not ready. errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      description: Backup plan {{$labels.backupplan}} is not ready.
      summary: Backup plan {{$labels.backupplan}} is not ready.
    expr: backupplan_status{ready="false"}
    for: 5m
    labels:
      severity: warning
  - alert: BackupJobFailed
    annotations:
      content: 'Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}}
        in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} failed:
        errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      description: Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}}
        in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} failed.
      summary: Backup job {{$labels.backupjob}} failed.
    expr: 'backupjob_status{status="Failed"} > 0 unless on(backupjob) (backupjob_status{status="Failed"}
      offset 1m) unless on() absent(up{service="mig-controller-metrics"} offset 1m)
      # the offset "1m" need to be greater than interval config in above servicemonitor'
    labels:
      severity: warning
  - alert: SelfBackupFailed
    annotations:
      content: YS1000 Self backup failed.
      description: YS1000 Self backup failed.
      summary: YS1000 Self backup failed.
    expr: selfbackup_status{enabled="true", state!="Succeeded"}
    labels:
      severity: warning
  - alert: BackupJobValidationError
    annotations:
      content: 'Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}}
        in cluster {{$labels.migcluster}} using storage {{$labels.migstorage}} validation
        error: errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      description: Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}}
        in cluster {{$labels.migcluster}} validation error.
      summary: Backup job {{$labels.backupjob}} validation error.
    expr: backupjob_status{status="ValidationError"}
    labels:
      severity: warning
  - alert: BackupJobLongRunning
    annotations:
      content: 'Backup job {{$labels.backupjob}} to backup namespace {{$labels.namespaces}}
        stay running for long time: errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      description: Backup job {{$labels.backupjob}} in namespace {{$labels.namespaces}}
        stay running for long time.
      summary: 'Backup job {{$labels.backupjob}} stay running for long time: {{$value}}
        seconds.'
    expr: backupjob_running_time_seconds > 3600
    labels:
      severity: warning
  - alert: VolumeSnapshotContentCountExceeded
    annotations:
      content: '{{$labels.snapshot_count}} VolumeSnapshotContents for pvc {{$labels.snapshot_namespace}}/{{$labels.pvc_name}}
        on cluster {{$labels.cluster}} exceeds limit {{$labels.snapshot_limit}}, backup
        plans are {{$labels.backupplans}}.'
      description: '{{$labels.snapshot_count}} VolumeSnapshotContents for pvc {{$labels.snapshot_namespace}}/{{$labels.pvc_name}}
        on cluster {{$labels.cluster}} exceeds limit {{$labels.snapshot_limit}}, backup
        plans are {{$labels.backupplans}}.'
      summary: VolumeSnapshotContents for pvc {{$labels.snapshot_namespace}}/{{$labels.pvc_name}}
        on cluster {{$labels.cluster}} exceeds limit.
    expr: volume_snapshot_content_count_exceeded{exceeded="true"}
    for: 30m
    labels:
      severity: warning
- name: ys1000-dr-healthy
  rules:
  - alert: DrConfigNotReady
    annotations:
      content: 'DrConfig {{$labels.name}} is not ready, please check immediately.
        errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      description: DrConfig {{$labels.name}} is not ready.
      summary: DrConfig {{$labels.name}} is not ready.
    expr: dr_config_status == 0
    for: 5m
    labels:
      alertSource: ys1000-dr
      severity: critical
  - alert: DrInstanceNotReady
    annotations:
      content: 'DrInstance {{$labels.name}} is not ready, please check immediately.
        errors: {{$labels.errors}}. warnings: {{$labels.warnings}}.'
      description: DrInstance {{$labels.name}} is not ready.
      summary: DrInstance {{$labels.name}} is not ready.
    expr: dr_instance_status == 0
    for: 5m
    labels:
      alertSource: ys1000-dr
      severity: critical
  - alert: DrInstanceDataRPOLagging
    annotations:
      content: 'DrInstance {{$labels.name}} data rpo lagging more than 5 minutes.
        current lagging: {{ $value }}s'
      description: DrInstance {{$labels.name}} data rpo lagging.
      summary: DrInstance {{$labels.name}} data rpo lagging more than 5 minutes.
    expr: 36000 > dr_instance_data_current_rpo - dr_instance_data_expected_rpo > 300
    for: 5m
    labels:
      alertSource: ys1000-dr
      severity: warnings
  - alert: DrInstanceDataRPOLaggingLong
    annotations:
      content: 'DrInstance {{$labels.name}} data rpo lagging more than 10 hours. current
        lagging: {{ $value }}s'
      description: DrInstance {{$labels.name}} data rpo lagging long.
      summary: DrInstance {{$labels.name}} data rpo lagging more than 10 hours.
    expr: dr_instance_data_current_rpo - dr_instance_data_expected_rpo > 36000
    for: 5m
    labels:
      alertSource: ys1000-dr
      severity: critical
  - alert: DrInstanceResourceRPOLagging
    annotations:
      content: 'DrInstance {{$labels.name}} resource rpo lagging more than 5 minutes.
        current lagging: {{ $value }}s'
      description: DrInstance {{$labels.name}} resource rpo lagging.
      summary: DrInstance {{$labels.name}} resource rpo lagging more than 5 minutes.
    expr: 36000 > dr_instance_resource_current_rpo - dr_instance_resource_expected_rpo
      > 300
    for: 5m
    labels:
      alertSource: ys1000-dr
      severity: warnings
  - alert: DrInstanceResourceRPOLaggingLong
    annotations:
      content: 'DrInstance {{$labels.name}} resource rpo lagging more than 10 hours.
        current lagging: {{ $value }}s'
      description: DrInstance {{$labels.name}} resource rpo lagging long.
      summary: DrInstance {{$labels.name}} resource rpo lagging more than 10 hours.
    expr: dr_instance_resource_current_rpo - dr_instance_resource_expected_rpo > 36000
    for: 5m
    labels:
      alertSource: ys1000-dr
      severity: critical
```

### 自定义告警规则

您也可以根据 YS1000 暴露的 metrics 自定义一些告警规则，各个 metric 的定义，包括 label 的定义以及 metric 值的定义请参见下文[Metrics 列表](#metrics-列表)一节。

## 配置 Alertmanager

最后，我们来配置 Alertmanager 来把告警发送出去。Alertmanager 内置支持对接多种消息平台，包括邮件、企业微信、slack以及webhook等。下面的示例配置 Alertmanager 的路由规则并最终把告警发送到企业微信：首先确保alertmanager的出口IP已经被添加到企业微信应用的白名单（管理员登录企业微信->应用管理->选择应用->企业可信IP->配置），然后把下面代码保存为 Alertmanager 配置文件到 Alertmanager 的配置目录，具体请参考[ Alertmanager 配置文档](https://prometheus.io/docs/alerting/latest/configuration/)（注意：请替换代码中尖括号(&lt;&gt;)内企业微信相关配置以匹配您的企业ID，agentID，secret，接收者账号等，具体请参考[企业微信文档](https://developer.work.weixin.qq.com/document/10013)。
```yaml
global:
  resolve_timeout: 5m
route:
  receiver: "null"
  group_by:
  - namespace
  routes:
  - receiver: ys1000/ys1000-alertmanager-config/default-receiver
    matchers:
    - namespace="ys1000"
    continue: true
    routes:
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      match:
        alertname: MigControllerAlive
      repeat_interval: 24h
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      match:
        alertname: MigControllerDown
      repeat_interval: 1h
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      group_by:
      - migcluster
      match:
        alertname: MigClusterNotReady
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      group_by:
      - migstorage
      match:
        alertname: MigStorageNotReady
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      group_by:
      - migstorage
      match:
        alertname: MigStorageUsageOverThreshold
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      group_by:
      - backupplan
      match:
        alertname: BackupPlanNotReady
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      group_by:
      - backupjob
      match:
        alertname: BackupJobLongRunning
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 30m
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      group_by:
      - backupjob
      match:
        alertname: BackupJobValidationError
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 30m
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      match:
        alertname: SelfBackupFailed
      group_wait: 0s
      group_interval: 1m
      repeat_interval: 5m
    - receiver: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
      group_by:
      - backupjob
      match:
        alertname: BackupJobFailed
      group_wait: 0s
      group_interval: 1m
      repeat_interval: 5m
    - receiver: "ys1000/ys1000-alertmanager-config/wechat-webhook-receiver"
      groupBy: ["disasterrecovery"]
      groupWait: 30s
      groupInterval: 5m
      repeatInterval: 30m
      matchers:
        - name: alertSource
          matchType: =
          value: ys1000-dr
  - receiver: "null"
    matchers:
    - alertname =~ "InfoInhibitor|Watchdog"
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
inhibit_rules:
- target_matchers:
  - severity =~ warning|info
  source_matchers:
  - severity = critical
  equal:
  - namespace
  - alertname
- target_matchers:
  - severity = info
  source_matchers:
  - severity = warning
  equal:
  - namespace
  - alertname
- target_matchers:
  - severity = info
  source_matchers:
  - alertname = InfoInhibitor
  equal:
  - namespace
- target_matchers:
  - alertname="BackupPlanNotReady"
  - namespace="ys1000"
  source_matchers:
  - alertname="MigClusterNotReady"
  - namespace="ys1000"
  equal:
  - migcluster
- target_matchers:
  - alertname="BackupPlanNotReady"
  - namespace="ys1000"
  source_matchers:
  - alertname="MigStorageNotReady"
  - namespace="ys1000"
  equal:
  - migstorage
receivers:
- name: "null"
- name: ys1000/ys1000-alertmanager-config/default-receiver
- name: ys1000/ys1000-alertmanager-config/wechat-webhook-receiver
  wechat_configs:
  - send_resolved: false
    api_secret: <替换为企业微信的 API 密钥>
    corp_id: <替换为企业微信的企业ID>
    agent_id: "<替换为企业微信的 agent_id >"
    to_user: "<替换为企业微信用户ID>"
    message: "{{- if gt (len .Alerts.Firing) 0 -}}\n{{- range $index, $alert := .Alerts
      -}}\n==========异常告警==========\n告警类型: {{ $alert.Labels.alertname }}\n告警级别: {{
      $alert.Labels.severity }}\n告警摘要: {{$alert.Annotations.summary}}\n告警描述: {{ $alert.Annotations.description}}\n告警详情:
      {{ $alert.Annotations.content }}\n故障时间: {{ ($alert.StartsAt.Add 28800e9).Format
      \"2006-01-02 15:04:05\" }}\nSource: {{ $alert.GeneratorURL }}\n============END============\n{{-
      end }}\n{{- end }}\nAlertmanager URL: {{ template \"__alertmanagerURL\" . }} "
```

示例中各个告警的 repeatInterval 可以按需求调整。

配置完成以后发送到企业微信的告警就类似于：

```
==========异常告警==========
告警类型: MigClusterNotReady
告警级别: warning
告警摘要: Cluster ccc is not ready.
告警描述: Cluster ccc is not ready, connected state is false.
告警详情: Cluster ccc is not ready, connected state is false. errors: . warnings: .
故障时间: 2022-09-15 11:23:32
Source: http://130.31.15.9:31828/graph?g0.expr=migcluster_status%7Bready%3D%22false%22%7D&g0.tab=1
============END============
Alertmanager URL: http://130.31.15.9:30445/#/alerts?receiver=qiming-migration%2Fys1000-alertmanager-config%2Fwebhook-and-wechat
```

其中 Source 和 Alertmanager URL 分别是 Prometheus 和 Alertmanager 的 WEB UI 地址，这两个地址需要分别在 Prometheus 和 Alertmanager 使用 --web.external-url 命令行参数正确配置才能访问；如果您使用 Prometheus Operator，对应的配置是 prometheuses.monitoring.coreos.com CR 和 alertmanagers.monitoring.coreos.com CR 的`.spec.externalUrl`字段。

# 参考

https://prometheus.io/docs/introduction/overview/

https://github.com/prometheus-operator/prometheus-operator

https://prometheus.io/docs/alerting/latest/notifications/

# Metrics 列表

## mail_delivery_status 邮件发送状态
(3.7.0 新增)

类型: gauge

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| type | 消息类型 | DailyReport
| state | 消息状态 | Succeeded, Failed

values: 消息发送时间

## wechat_delivery_status 微信发送状态
(3.7.0 新增)

类型: gauge

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| type | 消息类型 | DailyReport
| state | 消息状态 | Succeeded, Failed

values: 消息发送时间

## migcluster_status 集群状态

类型: gauge

lables:

| label 名   | 说明       | 可能取值    | 备注 |
| ---------- | ---------- | ----------- | ---- |
| migcluster | 集群名     |
| ready      | 是否就绪   | true, false |
| connected  | 是否已连接 | true, false |
| errors     | 错误代码   |
| warnings   | 错误代码   |

values:

0: 已就绪

1: 已连接未就绪

2: 未就绪

## migstorage_status 备份仓库状态

类型: gauge

labels:

| label 名   | 说明       | 可能取值    | 备注 |
| ---------- | ---------- | ----------- | ---- |
| migstorage | 备份仓库名 |
| ready      | 是否就绪   | true, false |
| errors     | 错误代码   |
| warnings   | 错误代码   |

values:

0: 已就绪

1: 未就绪

## migstorage_used_bytes 备份仓库已使用容量
(3.5.0 新增)

类型: gauge

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| migstorage | 备份仓库名

values: 备份仓库已使用容量，单位为 byte

## migstorage_quota 备份仓库配置的配额
(3.5.0 新增)

类型: gauge

labels:

| label名 | 说明 | 可能取值 | 备注 |
|---------|------|----------|------|
| migstorage | 备份仓库名

values: 备份仓库配置的配额，单位为 byte

## backupplan_status 备份计划状态

类型: gauge

labels:

| label 名   | 说明           | 可能取值    | 备注 |
| ---------- | -------------- | ----------- | ---- |
| backupplan | 备份计划名     |
| migcluster | 集群名         |
| namespaces | 备份命名空间   |
| repeat     | 是否是定时备份 | true, false |
| export     | 是否导出       | true, false |
| ready      | 是否就绪       | true, false |
| errors     | 错误代码       |
| warnings   | 错误代码       |

values:

0: 已就绪

1: 未就绪

## backupjob_status 备份任务状态

类型: gauge

labels:

| label 名   | 说明         | 可能取值                                                                   | 备注 |
| ---------- | ------------ | -------------------------------------------------------------------------- | ---- |
| backupjob  | 备份任务名   |
| backupplan | 备份计划名   |
| migcluster | 集群名       |
| migstorage | 备份仓库名   |
| namespaces | 备份命名空间 |
| pvs        | 持久卷个数   |
| export     | 是否导出     | true, false                                                                |
| status     | 状态         | Failed Succeeded Running Queued Canceled ValidationError Canceling Warning |
| errors     | 错误代码     |
| warnings   | 错误代码     |

values: 始终是 1

## selfbackup_status 自备份状态

(3.4.0 新增)

类型: gauge
labels:

| label 名 | 说明             | 可能取值                    | 备注 |
| -------- | ---------------- | --------------------------- | ---- |
| enabled  | 是否已启用自备份 | true false                  |
| state    | 自备份状态       | Succeeded Failed InProgress |

value: unix time of last successful/failed self backup, 0.0 otherwise.

## backupjob_running_time_seconds 备份任务运行时间

类型: counter

labels:

| label 名   | 说明         | 可能取值    | 备注 |
| ---------- | ------------ | ----------- | ---- |
| backupjob  | 备份任务名   |
| backupplan | 备份计划名   |
| migcluster | 集群名       |
| migstorage | 备份仓库名   |
| namespaces | 备份命名空间 |
| pvs        | 持久卷个数   |
| export     | 是否导出     | true, false |

values: 备份任务已运行时间，单位为秒

## processed_backupjob 已处理的备份任务数

类型: counter

labels:

| label 名   | 说明       | 可能取值                  | 备注 |
| ---------- | ---------- | ------------------------- | ---- |
| backupplan | 备份计划名 |
| status     | 状态       | Failed Succeeded Canceled |

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

## processed_volume_backup_size_bytes

(2.10.0 新增)

类型: counter

labels: 同“已处理的备份任务数”

values: 已完成的备份任务已处理的持久卷中的数量

## processing_volume_backup_size_bytes

(2.10.0 新增)

类型: gauge

labels:

| label 名   | 说明       | 可能取值 | 备注 |
| ---------- | ---------- | -------- | ---- |
| backupplan | 备份计划名 |
| backupjob  | 备份任务名 |

values: 进行中的备份任务已处理的持久卷中的数据量
