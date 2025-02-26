# 下载exporter
从官网下载最新exporter
https://prometheus.io/download/

# 安装exporter
- 解压下载好的exporter，放到/usr/loca/bin 路径

- 创建exporter运行用户 
```useradd --no-create-home --shell /bin/false node_exporter```

- 编辑守护文件 
```/usr/lib/systemd/system/node_exporter.service```
内容如下
```
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:39100

[Install]
WantedBy=multi-user.target
```

- 编辑配置文件 ```/etc/sysconfig/node_exporter```
内容如下
```
OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector --web.listen-address=:39100"
```

- 启动exporter
```
systemctl daemon-reload 
systemctl enable node_exporter.service
systemctl start node_exporter
systemctl status node_exporter
```