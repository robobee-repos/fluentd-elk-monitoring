es-service-yaml(parent, vars) ::= <<
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-logging
  namespace: kube-system
  labels:
    k8s-app: elasticsearch-logging
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: db
  - port: 9300
    protocol: TCP
    targetPort: transport
  selector:
    k8s-app: elasticsearch-logging

>>
