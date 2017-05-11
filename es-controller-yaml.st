es-controller-yaml(parent, vars) ::= <<
apiVersion: v1
kind: ReplicationController
metadata:
  name: elasticsearch-logging-v1
  namespace: kube-system
  labels:
    k8s-app: elasticsearch-logging
    version: v1
spec:
  replicas: 1
  selector:
    k8s-app: elasticsearch-logging
    version: v1
  template:
    metadata:
      labels:
        k8s-app: elasticsearch-logging
        version: v1
        kubernetes.io/cluster-service: "true"
    spec:
      containers:
      - image: <vars.elasticsearch.image.name>:<vars.elasticsearch.image.version>
        name: elasticsearch-logging
        resources:
          limits:
            memory: <vars.elasticsearch.memory_mb>Mi
          requests:
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
          mountPath: /data
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
