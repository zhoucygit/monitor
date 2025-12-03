# 说明
BLACKBOX是 Prometheus 的“探针工具”，用于：
- 检测接口是否可访问
- 检测 HTTP 状态码
- 发送 GET/POST 请求
- 检查 TLS 证书
- ICMP ping 主机
- TCP 端口探测

github 地址https://github.com/prometheus/blackbox_exporter

# 配置文件实例
github中查看example.yml中详细用法用法
以下为个人环境中实际示例
```
modules:
  http_2xx_example:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
      valid_status_codes: []  # Defaults to 2xx
      method: GET
      headers:
        Host: vhost.example.com
        Origin: example.com
      http_headers:
        Accept-Language:
          values:
            - "en-US"
      follow_redirects: true
      fail_if_ssl: false
      fail_if_not_ssl: false
      fail_if_body_matches_regexp:
        - "Could not connect to database"
      fail_if_body_not_matches_regexp:
        - "Download the latest version here"
      fail_if_header_matches: # Verifies that no cookies are set
        - header: Set-Cookie
          allow_missing: true
          regexp: '.*'
      fail_if_header_not_matches:
        - header: Access-Control-Allow-Origin
          regexp: '(\*|example\.com)'
      tls_config:
        insecure_skip_verify: false
      preferred_ip_protocol: "ip4" # defaults to "ip6"
      ip_protocol_fallback: false  # no fallback to "ip6"
  http_with_proxy:
    prober: http
    http:
      proxy_url: "http://127.0.0.1:3128"
      skip_resolve_phase_with_proxy: true
  http_with_proxy_and_headers:
    prober: http
    http:
      proxy_url: "http://127.0.0.1:3128"
      proxy_connect_header:
        Proxy-Authorization:
          - Bearer token
  http_post_2xx:
    prober: http
    timeout: 5s
    http:
      method: POST
      headers:
        Content-Type: application/json
      body: '{}'
  http_post_body_file:
    prober: http
    timeout: 5s
    http:
      method: POST
      body_file: "/files/body.txt"
  http_basic_auth_example:
    prober: http
    timeout: 5s
    http:
      method: POST
      headers:
        Host: "login.example.com"
      basic_auth:
        username: "username"
        password: "mysecret"
  http_json_cel_match:
    prober: http
    timeout: 5s
    http:
      method: GET
      fail_if_body_json_not_matches_cel: "body.foo == 'bar' && body.baz.startsWith('q')" # { "foo": "bar", "baz": "qux" }
  http_2xx_oauth_client_credentials:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      follow_redirects: true
      preferred_ip_protocol: "ip4"
      valid_status_codes:
        - 200
        - 201
      oauth2:
        client_id: "client_id"
        client_secret: "client_secret"
        token_url: "https://api.example.com/token"
        endpoint_params:
          grant_type: "client_credentials"
  http_custom_ca_example:
    prober: http
    http:
      method: GET
      tls_config:
        ca_file: "/certs/my_cert.crt"
  http_gzip:
    prober: http
    http:
      method: GET
      compression: gzip
  http_gzip_with_accept_encoding:
    prober: http
    http:
      method: GET
      compression: gzip
      headers:
        Accept-Encoding: gzip
  tls_connect:
    prober: tcp
    timeout: 5s
    tcp:
      tls: true
  tcp_connect_example:
    prober: tcp
    timeout: 5s
  imap_starttls:
    prober: tcp
    timeout: 5s
    tcp:
      query_response:
        - expect: "OK.*STARTTLS"
        - send: ". STARTTLS"
        - expect: "OK"
        - starttls: true
        - send: ". capability"
        - expect: "CAPABILITY IMAP4rev1"
  smtp_starttls:
    prober: tcp
    timeout: 5s
    tcp:
      query_response:
        - expect: "^220 ([^ ]+) ESMTP (.+)$"
        - send: "EHLO prober\r"
        - expect: "^250-STARTTLS"
        - send: "STARTTLS\r"
        - expect: "^220"
        - starttls: true
        - send: "EHLO prober\r"
        - expect: "^250-AUTH"
        - send: "QUIT\r"
  irc_banner_example:
    prober: tcp
    timeout: 5s
    tcp:
      query_response:
        - send: "NICK prober"
        - send: "USER prober prober prober :prober"
        - expect: "PING :([^ ]+)"
          send: "PONG ${1}"
        - expect: "^:[^ ]+ 001"
  rabbitmq:
    prober: tcp
    timeout: 30s
    tcp:
      query_response:
        - send: "HELO\r"
        - send: "\r"
        - send: "\r"
        - send: "\r"
        - expect: "AMQP"
      tls: true
      tls_config:
        insecure_skip_verify: false
        ca_file: "/etc/blackbox_exporter/CA_cert.crt"
  rabbitmq_insecure:
    prober: tcp
    timeout: 30s
    tcp:
      query_response:
        - send: "HELO\r"
        - send: "\r"
        - send: "\r"
        - send: "\r"
        - expect: "AMQP"
      tls: true
      tls_config:
        insecure_skip_verify: true
        ca_file: "/etc/blackbox_exporter/CA_cert.crt"
  icmp_example:
    prober: icmp
    timeout: 5s
    icmp:
      preferred_ip_protocol: "ip4"
      source_ip_address: "127.0.0.1"
  dns_udp_example:
    prober: dns
    timeout: 5s
    dns:
      query_name: "www.prometheus.io"
      query_type: "A"
      valid_rcodes:
        - NOERROR
      validate_answer_rrs:
        fail_if_matches_regexp:
          - ".*127.0.0.1"
        fail_if_all_match_regexp:
          - ".*127.0.0.1"
        fail_if_not_matches_regexp:
          - "www.prometheus.io.\t300\tIN\tA\t127.0.0.1"
        fail_if_none_matches_regexp:
          - "127.0.0.1"
      validate_authority_rrs:
        fail_if_matches_regexp:
          - ".*127.0.0.1"
      validate_additional_rrs:
        fail_if_matches_regexp:
          - ".*127.0.0.1"
  dns_soa:
    prober: dns
    dns:
      query_name: "prometheus.io"
      query_type: "SOA"
  dns_tcp_example:
    prober: dns
    dns:
      transport_protocol: "tcp" # defaults to "udp"
      preferred_ip_protocol: "ip4" # defaults to "ip6"
      query_name: "www.prometheus.io"
  unix_socket_ping:
    prober: unix
    timeout: 5s
    unix:
      query_response:
        - send: "PING"
        - expect: "PONG"
  postgresql:
    prober: tcp
    tcp:
      query_response:
      - send: !!binary AAAACATSFi8= # 0x00, 0x00, 0x00, 0x08, 0x04, 0xD2, 0x16, 0x2F - PostgreSQL SSLRequest
      - expect_bytes: S # 0x53 - Reply will be 'S' if SSL is enabled, and 'N' if it is not.
      - starttls: true
  http_with_header_from_files:
    prober: http
    http:
      http_headers:
        X-API-Key:
          files:
            - /path/to/api-key.txt
```


# prometheus 调用blackbox
```
编辑 Prometheus 配置：
/middleware/prometheus/prometheus.yml

scrape_configs:
  - job_name: 'blackbox_http_get'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - https://www.baidu.com
          - https://www.google.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: 10.100.12.11:9115   # blackbox IP 和端口
      - source_labels: [__param_target]
        target_label: instance

  - job_name: 'blackbox_post_json'
    metrics_path: /probe
    params:
      module: [http_post_json]
    static_configs:
      - targets:
          - http://10.100.12.50:8000/api/chat
          - http://10.100.12.50:8000/api/embedding
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: 10.100.12.11:9115
      - source_labels: [__param_target]
        target_label: instance
```


# 常用指标：
指标名	含义
probe_success	1 = 成功，0 = 失败
probe_http_status_code	HTTP 状态码
probe_duration_seconds	请求耗时
probe_dns_lookup_time_seconds	DNS 解析时间
probe_tls_*	TLS 信息（证书有效期等）

你可以用 Grafana 做 dashboard 图。


# Blackbox 探测 POST/JSON 示例（浏览器测试）

直接访问：

http://10.100.12.11:9115/probe?module=http_post_json&target=http://10.100.12.50:8000/api/chat


你会看到：

probe_success 1
probe_http_status_code 200
probe_duration_seconds 0.123


# 告警规则示例（生产可用）
/middleware/prometheus/rules/blackbox_rules.yml
groups:
  - name: blackbox_alerts
    rules:
      - alert: API_Down
        expr: probe_success == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "接口不可达"
          description: "接口 {{ $labels.instance }} 探测失败"

      - alert: API_Slow
        expr: probe_duration_seconds > 1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "接口响应慢"
          description: "接口 {{ $labels.instance }} 响应耗时 {{ $value }} 秒"