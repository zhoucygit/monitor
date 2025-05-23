# k8s集群配置
1、更改master节点中监听端口
/etc/kubernetes/manifests中controleer和sceduler，将监听端口改为0.0.0.0 改完后删除相应pod重新生成

2、推荐方式：为每个节点部署一个独立的 cAdvisor 容器并显式暴露
这是最安全也最常见的做法。

✅ 步骤如下：
1. 为每个节点部署独立的 cAdvisor服务

2、
✅ 你的 Prometheus 环境参数汇总
组件	地址或端口	状态
kube-apiserver	https://10.100.12.11:6443	已知地址
kubelet	https://<node>:10250/metrics	curl 测试通过
kube-controller-manager	https://<master>:10257/metrics	静态目标已配置
kube-scheduler	https://<master>:10259/metrics	静态目标已配置
etcd	https://<master>:2379/metrics	静态目标已配置
node-exporter	http://<node>:9100/metrics	静态目标已配置
kube-state-metrics	http://<node>:8080/metrics	静态目标已配置
cAdvisor	http://<node>:28848/metrics	静态目标已配置
CA 与 token 路径	/middleware/prometheus/	
Prometheus 部署方式	Docker	
Prometheus 数据路径	/middleware/prometheus/data



docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /middleware/prometheus/conf/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /middleware/prometheus/data:/prometheus \
  -v /middleware/prometheus/certs:/etc/prometheus/certs/ \
  192.168.10.212/middleware/prometheus_arm64:v3.4.0


```
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'kube-apiserver'
    scheme: https
    static_configs:
      - targets: 
        - '10.100.12.11:6443'
        - '10.100.12.12:6443'
        - '10.100.12.13:6443'
    tls_config:
      ca_file: /middleware/prometheus/ca.crt
    bearer_token_file: /middleware/prometheus/token
    metrics_path: /metrics
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance

  - job_name: 'kubelet'
    scheme: https
    static_configs:
      - targets: 
        - 10.100.12.11:10250
        - 10.100.12.12:10250
        - 10.100.12.13:10250
        - 10.100.12.2:10250
        - 10.100.12.3:10250
        - 10.100.12.4:10250
    tls_config:
      insecure_skip_verify: true
    bearer_token_file: /middleware/prometheus/token
    metrics_path: /metrics

  - job_name: 'kube-controller-manager'
    scheme: https
    static_configs:
      - targets: ['10.100.12.11:10257']
    tls_config:
      insecure_skip_verify: true
    metrics_path: /metrics

  - job_name: 'kube-scheduler'
    scheme: https
    static_configs:
      - targets: ['10.100.12.11:10259']
    tls_config:
      insecure_skip_verify: true
    metrics_path: /metrics

  - job_name: 'etcd'
    scheme: https
    static_configs:
      - targets: ['10.100.12.11:2379']
    tls_config:
      insecure_skip_verify: true
    metrics_path: /metrics

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['10.100.12.11:9100', '10.100.12.12:9100', '10.100.12.13:9100']

  - job_name: 'kube-state-metrics'
    static_configs:
      - targets: ['10.100.12.11:8080']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['10.100.12.11:28848', '10.100.12.12:28848', '10.100.12.13:28848']

```


# 监控etcd
从k8smaster节点拷贝证书  /etc/kubernetes/pki/etcd
更改权限
chmod 644 etcd/*