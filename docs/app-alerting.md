# Application Alerting

## Overview

The `nginx-lab` Helm chart includes a `PrometheusRule` resource for application-specific alerts.

The alerts are discovered by the Prometheus Operator and evaluated by Prometheus.

## Resources

The chart creates:

- `PrometheusRule/nginx-lab`

The rule is enabled with:

```yaml
prometheusRule:
  enabled: true
```

## Alerts

### NginxLabDeploymentReplicasUnavailable

Expression:

```promql
kube_deployment_status_replicas_available{namespace="devops-lab", deployment="nginx-lab"} < 1
```

Purpose:

Detects when the `nginx-lab` Deployment has no available replicas.

### NginxLabHighRequestRate

Expression:

```promql
sum(rate(nginx_http_requests_total{namespace="devops-lab"}[5m])) > 5
```

Purpose:

Detects when the app receives more than 5 requests per second over a 5-minute window.

## Validation Commands

Verify Helm release:

```bash
helm status nginx-lab -n devops-lab
```

Verify the rule exists:

```bash
kubectl get prometheusrule nginx-lab -n devops-lab
kubectl get prometheusrule nginx-lab -n devops-lab -o yaml
```

Check Prometheus:

```text
Prometheus → Status → Rules
```

Search for:

```text
NginxLab
```

Check alerts:

```text
Prometheus → Alerts
```

## Replica Alert Test

Scale the app to zero:

```bash
kubectl scale deployment nginx-lab -n devops-lab --replicas=0
```

Wait for the alert to fire.

Restore the app:

```bash
kubectl scale deployment nginx-lab -n devops-lab --replicas=3
kubectl rollout status deployment nginx-lab -n devops-lab
```

## High Request Rate Alert Test

Generate traffic:

```bash
kubectl delete pod traffic-test -n devops-lab --ignore-not-found

kubectl run traffic-test \
  -n devops-lab \
  --restart=Never \
  --image=curlimages/curl \
  --command -- sh -c 'for i in $(seq 1 3000); do curl -s http://nginx-lab:80 > /dev/null; done'

kubectl logs traffic-test -n devops-lab
kubectl delete pod traffic-test -n devops-lab
```

Check request rate in Prometheus:

```promql
sum(rate(nginx_http_requests_total{namespace="devops-lab"}[5m]))
```

## Alertmanager Validation

Find the Alertmanager service:

```bash
kubectl get svc -n monitoring | grep -i alert
```

Port-forward:

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093
```

Open:

```text
http://127.0.0.1:9093
```

## Skills Practiced

- PrometheusRule custom resources

- PromQL alert expressions

- Alert testing

- Alertmanager validation

- Helm-managed observability resources