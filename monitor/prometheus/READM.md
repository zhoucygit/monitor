# 手工添加target

在monitoring命名空间中找到配置文件monitoring/additional-configs  （已secret形式存在 ），按照job名称形式添加target，如下所示，添加完后会自动发现
```
- job_name: 'ceph-monitor'
  metrics_path: /metrics
  scrape_interval: 30s
  scrape_timeout: 10s
  static_configs:
    - targets:
      - 192.168.10.149:9100
      - 192.168.10.150:9100
      - 192.168.10.151:9100
- job_name: 'node-exporter-mysql'
  metrics_path: /metrics
  scrape_interval: 30s
  scrape_timeout: 10s
  static_configs:
    - targets:
      - 172.168.1.245:39100
      - 172.168.1.246:39100
- job_name: 'custom_exporter'
  static_configs:
    - targets:
      - 192.168.10.232:9111
- job_name: 'dc_task_execution_info_monitor'
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /dc_task_execution_info_monitor/metrics
  static_configs:
    - targets:
      - 192.168.10.232:9111
  metric_relabel_configs:
    - source_labels: [exported_instance]
      target_label: instance
    - regex: ^exported_instance$
      action: labeldrop

- job_name: 'zhonghe_saas_new_inet_data_monitor'
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /zhonghe_saas_new_inet_data_monitor/metrics
  static_configs:
    - targets:
      - 192.168.10.232:9111
  metric_relabel_configs:
    - source_labels: [exported_instance]
      target_label: instance
    - regex: ^exported_instance$
      action: labeldrop

- job_name: 'zhonghe_saas_new_data_gov_pending_monitor'
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /zhonghe_saas_new_data_gov_pending_monitor/metrics
  static_configs:
    - targets:
      - 192.168.10.232:9111
  metric_relabel_configs:
    - source_labels: [exported_instance]
      target_label: instance
    - regex: ^exported_instance$
      action: labeldrop
```


# 配置告警

编辑configmap中找prometheus-k8s-rulefiles-0，编辑相应的rulefile文件
```

```