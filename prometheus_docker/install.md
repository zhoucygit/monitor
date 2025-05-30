[toc]
# 修改k8s监听地址

将以下两个文件中监听端口由127.0.0.1 修改为0.0.0.0
改完后它会自动删除controller 和 scheduler pod 重新生成
/etc/kubernetes/manifests/kube-controller-manager.yaml
/etc/kubernetes/manifests/kube-scheduler.yaml

# 准备证书及token
## 创建并获取k8s集群token

创建账户并赋予角色
```
kubectl apply -f kubesa.yml
kubectl -n monitoring get secrets 
```
将token复制出来另存为文件k8s.token

## 拷贝etcd证书
将集群中etcd证书文件夹拷贝出来 
```
/etc/kubernetes/pki/etcd/
```



# 为每个节点部署独立的 cAdvisor服务
## 准备资源
去git上下载相应的包，放置到/middleware 路径，更改cadvisor-v0.52.1-linux-arm64文件权限为755 
目录结构如下

``` 
cadvisor/
├── bin
│   └── cadvisor-v0.52.1-linux-arm64
└── logs



cat /etc/systemd/system/cadvisor.service 
[Unit]
Description=cAdvisor Service
After=network.target docker.service
Requires=docker.service

[Service]
ExecStart=/middleware/cadvisor/bin/cadvisor-v0.52.1-linux-arm64 \
  --port=28848 \
  --log_dir=/middleware/cadvisor/logs/ \
  --docker_only=false \
  --docker=unix:///var/run/docker.sock \
  --housekeeping_interval=30s
Restart=always

[Install]
WantedBy=multi-user.target
```



## 启动cadvisor

```

systemctl daemon-reload &&  systemctl enable cadvisor && systemctl start cadvisor

```



# k8s指标采集
## 安装kube-state-metrics
kube-state-metrics 是一个用于从 Kubernetes 集群中生成各种资源对象状态指标的工具。

通过Deployment等配置完成安装
https://github.com/kubernetes/kube-state-metrics/tree/main/examples/standard
通过以下命令进行安装
该方式会去找kustomization.yaml文件，按照顺序进行安装
```
root@vm-10-100-12-11:/data/package/monitoring/kube-state-metrics-main/examples# kubectl apply -k standard/
serviceaccount/kube-state-metrics created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
service/kube-state-metrics created
deployment.apps/kube-state-metrics created
```

kube-state-metrics  默认是headless ，删除clusterip： none的相关行再部署，部署完后改成nodeport


## 常见指标
```
kube_pod_info # 有关pod的信息。
kube_pod_start_time # pod的unix时间戳记中的开始时间。
kube_pod_completion_time #pod的unix时间戳记中的完成时间。
kube_pod_labels # Kubernetes标签转换为Prometheus标签。
kube_pod_status_phase # Pod当前阶段。
kube_pod_status_ready # 描述容器是否准备好处理请求。
kube_pod_status_scheduled # 描述pod的调度过程的状态。
kube_pod_container_info # 有关容器中container的信息。
kube_pod_container_status_waiting # 描述容器当前是否处于等待状态。
kube_pod_container_status_waiting_reason # 描述容器当前处于等待状态的原因。
kube_pod_container_status_running # 描述容器当前是否处于运行状态。
kube_pod_container_status_terminated # 描述容器当前是否处于终止状态。
kube_pod_container_status_terminated_reason # 描述容器当前处于终止状态的原因。
kube_pod_container_status_last_terminated_reason # 描述容器处于终止状态的最后原因。
kube_pod_container_status_ready # Describes whether the containers readiness check succeeded.
kube_pod_container_status_restarts_total # 每个容器的容器重新启动次数。
kube_pod_container_resource_requests # 容器请求的请求资源数。
kube_pod_container_resource_limits # 容器请求的限制资源数量。
kube_pod_overhead # 额外资源开销，通常会衍生kube_pod_overhead_memory_bytes 与kube_pod_overhead_cpu_cores  
kube_pod_created # Unix创建时间戳。
kube_pod_deletion_timestamp # Unix删除时间戳
kube_pod_restart_policy # 描述此pod使用的重新启动策略。
kube_pod_init_container_info # 有关Pod中init容器的信息。
kube_pod_init_container_status_waiting # ，描述初始化容器当前是否处于等待状态。
kube_pod_init_container_status_waiting_reason # Describes the reason the init container is currently in waiting state.
kube_pod_init_container_status_running # 描述初始化容器当前是否处于运行状态。
kube_pod_init_container_status_terminated # 描述初始化容器当前是否处于终止状态。
kube_pod_init_container_status_terminated_reason # 描述初始化容器当前处于终止状态的原因。
kube_pod_init_container_status_last_terminated_reason # 描述初始化容器处于终止状态的最后原因。
kube_pod_init_container_status_ready # 描述初始化容器准备情况检查是否成功。
kube_pod_init_container_status_restarts_total  #Counter类型，初始化容器的重新启动次数。    
kube_pod_init_container_resource_limits # 初始化容器请求的限制资源数。
kube_pod_spec_volumes_persistentvolumeclaims_info # 有关Pod中持久卷声明卷的信息。
kube_pod_spec_volumes_persistentvolumeclaims_readonly # 描述是否以只读方式安装了持久卷声明。
kube_pod_status_reason # pod状态原因
kube_pod_status_scheduled_time # Pod移至计划状态时的Unix时间戳
kube_pod_status_unschedulable # 描述pod的unschedulable状态。

```


# 启动prometheus

## 启动
``` 
prometheus/
├── certs
│   ├── 10.100.12.11
│   │   ├── etcd
│   │   └── k8s.token
│   └── 192.168.10.231
│       ├── etcd
│       └── k8s.token
├── conf
│   └── prometheus.yml
├── data
└── docker-compose.yml


docker compose up -d
```


## 修改数据路径所有者
```
chown -R 65534:65534 promethus_data
chown -R 65534:65534 alertmanager_data/
chown -R 472:472  grafana_data
```





