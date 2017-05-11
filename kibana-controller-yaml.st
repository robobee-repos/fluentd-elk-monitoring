kibana-controller-yaml(parent, vars) ::= <<
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kibana-logging
  namespace: kube-system
  labels:
    k8s-app: kibana-logging
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: kibana-logging
  template:
    metadata:
      labels:
        k8s-app: kibana-logging
    spec:
      containers:
      - name: kibana-logging
        image: <vars.kibana.image.name>:<vars.kibana.image.version>
        resources:
          limits:
            cpu: 50m
            memory: 80Mi
          requests:
            cpu: 50m
            memory: 80Mi
        env:
          - name: "ELASTICSEARCH_URL"
            value: "http://elasticsearch-logging:9200"
          - name: "KIBANA_BASE_URL"
            value: "/api/v1/proxy/namespaces/kube-system/services/kibana-logging"
        ports:
        - containerPort: 5601
          name: ui
          protocol: TCP

>>
