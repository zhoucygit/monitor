# 本文档是容器化部署prometheus，并监控k8s集群
# 监控资源列表

|资源 | 默认端口 | 获取方式 |
|:----------|:-------------|:------|
|kube-apiserver | https://10.100.12.11:6443 | k8s集群默认暴露 |
|kubelet | https://:10250/metrics | k8s集群默认暴露|
|kube-controller-manager | https://:10257/metrics | k8s集群暴露，需要修改配置文件监听到0.0.0.0|
|kube-scheduler | https://:10259/metrics | k8s集群暴露，需要修改配置文件监听到0.0.0.0|
|etcd | https://:2379/metrics | k8s集群默认暴露|
|node-exporter | http://:19100/metrics | k8s集群外单独安装，建议修改默认监听端口9100，防止冲突|
|kube-state-metrics | http://:8080/metrics | k8s集群内部署安装|
|cAdvisor | http://:28848/metrics  | k8s集群外单独安装|