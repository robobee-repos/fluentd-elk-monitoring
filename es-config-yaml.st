es-config-yaml(parent, vars) ::= <<
kind: ConfigMap
apiVersion: v1
metadata:
  name: elasticsearch-logging-config
  namespace: kube-system
data:
  elasticsearch.yml: |-
    path:
      logs: /var/log/elasticsearch
      data: /data
    cluster.name: <vars.elasticsearch.cluster.name>
    network.host: 0.0.0.0
    bootstrap.memory_lock: true
    discovery.zen.ping.unicast.hosts:
      - elasticsearch-logging
    discovery.zen.minimum_master_nodes: <vars.elasticsearch.master_nodes>
    xpack.security.enabled: false
  log4j2.properties: |-
    status = error

    appender.console.type = Console
    appender.console.name = console
    appender.console.layout.type = PatternLayout
    appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

    rootLogger.level = info
    rootLogger.appenderRef.console.ref = console

>>