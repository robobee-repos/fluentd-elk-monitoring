es-controller-yaml(parent, vars) ::= <<
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: elasticsearch-logging-v1
  namespace: kube-system
  labels:
    k8s-app: elasticsearch-logging
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: elasticsearch-logging
  template:
    metadata:
      labels:
        k8s-app: elasticsearch-logging
    spec:
      containers:
      - image: <vars.elasticsearch.image.name>:<vars.elasticsearch.image.version>
        name: elasticsearch-logging
        command:
          - bin/elasticsearch
          - -Epath.conf=/config
        resources:
          limits:
            cpu: 1000m
            memory: <vars.elasticsearch.memory_mb>Mi
          requests:
            cpu: 100m
            memory: <vars.elasticsearch.memory_mb>Mi
        ports:
        - containerPort: 9200
          name: db
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - name: es-persistent-storage
          mountPath: /usr/share/elasticsearch/data
        - name: config-volume
          mountPath: /config
        env:
        - name: "ES_JAVA_OPTS"
          value: "-Xms<vars.elasticsearch.memory_mb>m -Xmx<vars.elasticsearch.memory_mb>m"
      volumes:
      - name: es-persistent-storage
        emptyDir: {}
      - name: config-volume
        configMap:
          name: elasticsearch-logging-config

>>
