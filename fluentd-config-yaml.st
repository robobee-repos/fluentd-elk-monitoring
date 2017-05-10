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
        custom_pattern_path /fluentd/etc/kubernetes.txt
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
      logstash_prefix k8s-pods_int_ams01
      logstash_dateformat "_%Y.%m.%d"
      logstash_format true
      buffer_chunk_limit 2m
      buffer_queue_limit 32
      flush_interval 5s
      max_retry_wait 30
      disable_retry_limit
      num_threads 8
    </match>
  systemd.conf: |-
    <source>
      @type systemd
      path /var/log/journal
      filters [{ "_SYSTEMD_UNIT": [ "etcd-member.service", "docker.service", "kubelet.service" ] }]
      pos_file /var/fluentd/systemd.pos
      tag systemd
      read_from_head true
      strip_underscores true
    </source>

    <filter systemd>
      @type parser
      key_name MESSAGE
      reserve_data true
      reserve_time true
      <parse>
        @type grok
        custom_pattern_path /fluentd/etc/systemd.txt
        grok_pattern time="%{TIMESTAMP_ISO8601:message_time}"\s+level=%{LOGLEVEL:message_level}\s+msg="%{DATA:message_message}"
      </parse>
    </filter>

    <match systemd>
      @type elasticsearch
      @log_level info
      include_tag_key true
      host "#{ENV['FLUENT_ELASTICSEARCH_HOST']}"
      port "#{ENV['FLUENT_ELASTICSEARCH_PORT']}"
      logstash_prefix systemd
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

>>
