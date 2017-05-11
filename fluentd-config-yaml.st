fluentd-config-yaml(parent, vars) ::= <<
kind: ConfigMap
apiVersion: v1
metadata:
  name: fluentd-config
  namespace: kube-system
data:
  kubernetes.conf: |-
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/fluentd/kubernetes.pos
      tag kubernetes.*
      read_from_head true
      format json
      time_format %Y-%m-%dT%H:%M:%S.%NZ
    </source>

    <filter kubernetes.**>
      @type parser
      key_name log
      reserve_data true
      reserve_time true
      <parse>
        @type grok
        custom_pattern_path /fluentd/conf.d/kubernetes.txt
        <grok>
          pattern %{CALICO}
        </grok>
        <grok>
          pattern %{KUBERNETES}
        </grok>
      </parse>
    </filter>

    <filter kubernetes.var.log.containers.**.log>
      @type kubernetes_metadata
    </filter>

    <match kubernetes.**>
      @type elasticsearch
      @log_level info
      include_tag_key true
      host "#{ENV['FLUENT_ELASTICSEARCH_HOST']}"
      port "#{ENV['FLUENT_ELASTICSEARCH_PORT']}"
      logstash_prefix "k8s-pods_int_ams01"
      logstash_dateformat "%Y.%m.%d"
      logstash_format true
      template_name "kubernetes-*"
      template_file "/fluentd/conf.d/kubernetes.json"
      buffer_chunk_limit 2m
      buffer_queue_limit 32
      flush_interval 5s
      max_retry_wait 30
      disable_retry_limit
      num_threads 8
    </match>
  journal.conf: |-
    <source>
      @type systemd
      path /var/log/journal
      filters [{ "_SYSTEMD_UNIT": [ "etcd.service", "docker.service", "kubelet.service" ] }]
      pos_file /var/fluentd/journal.pos
      tag journal
      read_from_head true
      strip_underscores true
    </source>

    <filter journal>
      @type parser
      key_name MESSAGE
      reserve_data true
      reserve_time true
      <parse>
        @type grok
        custom_pattern_path /fluentd/conf.d/journal.txt
        grok_pattern time="%{TIMESTAMP_ISO8601:message_time}"\s+level=%{LOGLEVEL:message_level}\s+msg="%{DATA:message_message}"
      </parse>
    </filter>

    <match journal>
      @type elasticsearch
      @log_level info
      include_tag_key true
      host "#{ENV['FLUENT_ELASTICSEARCH_HOST']}"
      port "#{ENV['FLUENT_ELASTICSEARCH_PORT']}"
      logstash_prefix journal
      logstash_dateformat "%Y.%m.%d"
      logstash_format true
      buffer_chunk_limit 2m
      buffer_queue_limit 32
      flush_interval 5s
      max_retry_wait 30
      disable_retry_limit
      num_threads 8
    </match>
  kubernetes.txt: |-
    KUBERNETES %{KUBE_LEVEL}%{KUBE_TIME:log_time}\s+%{INT}\s+%{K_MODULE}:%{K_LINE}\]\s+%{K_MESSAGE}

    KUBERNETES_DASHBOARD \[%{TIMESTAMP_ISO8601:log_time}\]\s+(:?Outcoming response to %{IPORHOST:log_http_clientip}:%{POSINT:log_http_clientport} with %{NUMBER:log_http_response} status code)|(:?Incoming HTTP/%{NUMBER:log_http_httpversion} %{WORD:log_http_verb} %{NOTSPACE:log_http_request} request from %{IPORHOST:log_http_clientip}:%{POSINT:log_http_clientport})

    GRAFANA t=%{TIMESTAMP_ISO8601:log_time} lvl=%{K_LEVEL_NAME} msg="%{DATA:log_message}"(:?\slogger=%{WORD:log_module})?(?:\sdir=%{DATA:log_dir})?

    INFLUXDB \[httpd\] %{IPORHOST:log_http_clientip} - %{HTTPDUSER:log_http_auth} \[%{HTTPDATE:log_time}\] "(?:%{WORD:log_http_verb} %{NOTSPACE:log_http_request}(?: HTTP/%{NUMBER:log_http_httpversion})?|%{DATA:log_http_rawrequest})" %{NUMBER:log_http_response} (?:%{NUMBER:log_http_bytes}|-)

    DNS_DNSMASQ %{K_MODULE}\[%{INT}\]:\s+%{K_MESSAGE}

    HEAPSTER_EVENTER %{KUBERNETES}

    CALICO %{CALICO_TIME:log_time}\s+%{CALICO_LEVEL}\s+%{K_MODULE}\s+%{K_LINE}:\s+%{K_MESSAGE}

    KUBE_LEVEL %{LETTER:log_level}
    KUBE_TIME %{MONTHNUM}%{MONTHDAY}\s%{TIME}

    CALICO_LEVEL \[%{K_LEVEL_NAME}\]\[%{INT}\]
    CALICO_TIME %{YEAR}-%{MONTHNUM}-%{MONTHDAY}[T ]%{TIME}

    K_LEVEL_NAME %{LOGLEVEL:log_level}
    K_MODULE %{GREEDYDATA:log_module}
    K_LINE %{INT:log_line}
    K_MESSAGE %{GREEDYDATA:log_message}

    LETTER \w
  systemd.txt:
  kubernetes.json: |-
    {
      "template": "kubernetes-*",
      "mappings": {
        "fluentd": {
          "properties": {
            "@timestamp": {
              "type": "date"
            },
            "docker": {
              "properties": {
                "container_id": {
                  "type": "keyword"
                }
              }
            },
            "kubernetes": {
              "properties": {
                "container_name": {
                  "type": "keyword"
                },
                "namespace_name": {
                  "type": "keyword"
                },
                "pod_name": {
                  "type": "keyword"
                }
              }
            },
            "log": {
              "type": "text",
              "index": "false"
            },
            "log_level": {
              "type": "keyword"
            },
            "log_line": {
              "type": "long"
            },
            "log_message": {
              "type": "keyword"
            },
            "log_module": {
              "type": "keyword"
            },
            "log_dir": {
              "type": "text",
              "index": "false"
            },
            "log_time": {
              "type": "date",
              "format": "yyyy-MM-dd HH:mm:ss.SSS||MMdd HH:mm:ss.SSSSSS|dd/MMMM/yyyy:HH:mm:ss Z"
            },
            "log_http_clientip": {
              "type": "ip"
            },
            "log_http_request": {
              "type": "text",
              "index": "false"
            },
            "log_http_bytes": {
              "type": "long"
            },
            "log_http_clientport": {
              "type": "int"
            },
            "log_http_rawrequest": {
              "type": "text",
              "index": "false"
            },
            "log_http_verb": {
              "type": "keyword"
            },
            "log_http_auth": {
              "type": "keyword"
            },
            "log_http_response": {
              "type": "int"
            },
            "log_http_httpversion": {
              "type": "keyword"
            },
            "message": {
              "type": "text",
              "index": "false"
            },
            "stream": {
              "type": "text",
              "index": "false"
            },
            "tag": {
              "type": "keyword"
            }
          }
        }
      }
    }

>>
