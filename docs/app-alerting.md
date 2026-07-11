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

## Validation

Verify the rule exists:

```bash
kubectl get prometheusrule nginx-lab -n devops-lab
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

## Alertmanager

Alertmanager receives firing alerts from Prometheus.

Port-forward example:

```bash
kubectl get svc -n monitoring
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