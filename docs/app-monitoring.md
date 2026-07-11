# Application Monitoring

## Overview

The `nginx-lab` application is monitored using an NGINX Prometheus exporter sidecar.

Each application pod contains:

- `nginx`
- `nginx-prometheus-exporter`

NGINX exposes a local-only `stub_status` endpoint, and the exporter converts that status output into Prometheus metrics.

## Architecture

```text
NGINX container
  :80
  /stub_status localhost only
        |
        v
nginx-prometheus-exporter sidecar
  :9113/metrics
        |
        v
Service metrics port
        |
        v
ServiceMonitor
        |
        v
Prometheus
```

## Helm Resources

The Helm chart defines:

- ConfigMap

- Deployment

- ClusterIP Service

- NodePort Service

- Ingress

- ServiceMonitor

## ConfigMap

The ConfigMap provides:

- `index.html`

- `default.conf`

The `default.conf` enables:

```nginx
location /stub_status {
  stub_status;
  access_log off;
  allow 127.0.0.1;
  deny all;
}
```

## Deployment

The Deployment runs two containers per pod:

```yaml
- name: nginx
- name: nginx-prometheus-exporter
```

The exporter uses:

```bash
-nginx.scrape-uri=http://127.0.0.1:80/stub_status
```

## Service

The main Service exposes:

```yaml
- name: http
  port: 80
- name: metrics
  port: 9113
```

## ServiceMonitor

The ServiceMonitor selects the app Service with:

```yaml
selector:
  matchLabels:
    app: nginx-lab
```    

It scrapes:

```yaml
endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
```    

## Validation Commands

Check pods:

```bash
kubectl get pods -n devops-lab
```

Check NGINX config:

```bash
POD_NAME=$(kubectl get pods -n devops-lab -l app=nginx-lab -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n devops-lab "$POD_NAME" -c nginx -- cat /etc/nginx/conf.d/default.conf
```

Check NGINX status:

```bash
kubectl exec -n devops-lab "$POD_NAME" -c nginx -- curl -s http://127.0.0.1/stub_status
```

Check exporter metrics:

```bash
kubectl port-forward -n devops-lab pod/"$POD_NAME" 9113:9113
curl http://127.0.0.1:9113/metrics | head
```

Check ServiceMonitor:

```bash
kubectl get servicemonitor nginx-lab -n devops-lab
kubectl get service nginx-lab -n devops-lab --show-labels
```

## Prometheus Queries

Active connections:

```promql
nginx_connections_active
```

Total requests:

```promql
nginx_http_requests_total
```

Request rate:

```promql
rate(nginx_http_requests_total[5m])
```

Generate traffic:

```bash
for i in {1..50}; do curl -s http://nginx-lab.10.10.10.201.nip.io:30081 > /dev/null; done
```

## In-Cluster Metrics Validation

A temporary curl pod was used to verify that the application Service exposes exporter metrics inside the cluster.

```bash
kubectl delete pod metrics-test -n devops-lab --ignore-not-found

kubectl run metrics-test \
  -n devops-lab \
  --restart=Never \
  --image=curlimages/curl \
  --command -- curl -v http://nginx-lab:9113/metrics

kubectl logs metrics-test -n devops-lab

kubectl delete pod metrics-test -n devops-lab
```
Expected result:

```text
HTTP/1.1 200 OK
# HELP nginx_connections_active Active client connections
# TYPE nginx_connections_active gauge
```

This validated:

- Kubernetes DNS resolution for the `nginx-lab` Service

- ClusterIP Service routing

- Metrics port `9113`

- NGINX exporter `/metrics` output

## Note About Temporary Test Pods

On this cluster/client version, `kubectl run --rm` required an attached container. The workaround was to create a temporary pod, read its logs, and then delete it manually.

## Skills Practiced

- Exporter sidecar pattern

- NGINX stub_status

- ConfigMap-backed NGINX config

- Service metrics ports

- Prometheus Operator ServiceMonitor

- PromQL queries for application metrics

- Helm troubleshooting