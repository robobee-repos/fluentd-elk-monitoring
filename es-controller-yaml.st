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
        env:
        - name: "cluster.name"
          value: <vars.elasticsearch.cluster.name>
        - name: "bootstrap.memory_lock"
          value: true
        - name: "ES_JAVA_OPTS"
          value: "-Xms<vars.elasticsearch.memory_mb>m -Xmx<vars.elasticsearch.memory_mb>m"
        - name: "discovery.zen.ping.unicast.hosts"
          value: "elasticsearch-logging"
      volumes:
      - name: es-persistent-storage
        emptyDir: {}

>>
