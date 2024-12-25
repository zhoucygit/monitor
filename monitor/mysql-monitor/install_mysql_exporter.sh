#!/bin/bash

#生成serviceMontor的endpoint
generate_serviceMonitor() {
  mysql_instance=$1
  url=$2
  cat << EOF 
  - interval: 15s
    port: $mysql_instance-mysql-monitor-port
    targetPort: 9104
    relabelings:
      - targetLabel: instance
        replacement: $mysql_instance-$url
EOF
}

#循环读取数据库列表,启动mysql-exporter容器
cat mysql.list | grep -v "实例名称" | while read line
do
  mysql_instance=$(echo $line | awk '{print $1}')
  ip=$(echo $line | awk '{print $2}')
  port=$(echo $line | awk '{print $3}')
  username=$(echo $line | awk '{print $4}')
  password=$(echo $line | awk '{print $5}')
  url="$ip:$port"
  # 创建secret，内容包含mysql的用户名密码以及url
  kubectl create secret generic $mysql_instance-mysql-secret --from-literal=url=$url --from-literal=username=$username --from-literal=password=$password -n monitoring
  # 创建mysql-exporter
  sed "s/\${mysql-instance}/$mysql_instance/g" yaml/mysql-exporter-deployment.yaml | kubectl apply -f -
  # 创建mysql服务
  sed "s/\${mysql-instance}/$mysql_instance/g" yaml/mysql-exporter-service.yaml | kubectl apply -f -
  # 调用generate_serviceMonitor函数，生成serviceMontor的endpoint内容写入到临时文件 mysql-serviceMonitor_tmp.yaml
  generate_serviceMonitor $mysql_instance $url >> mysql-serviceMonitor_tmp.yaml
done
#将生成的endpoint内容插入到yaml/mysql-exporter-serviceMonitor.yaml文件的第10行之后
sed '10r mysql-serviceMonitor_tmp.yaml' yaml/mysql-exporter-serviceMonitor.yaml | kubectl apply -f -
# 删除临时文件mysql-serviceMonitor_tmp.yaml
if [ $? -eq 0 ];then
  rm -f mysql-serviceMonitor_tmp.yaml
fi

