# Troubleshooting Notes

## Duplicate IP Addresses After Cloning Proxmox Cloud-Init Template

### Problem

After cloning multiple Ubuntu cloud-init VMs from the same Proxmox template, each VM received the same DHCP IP address. The duplicate IP was also the same IP address previously used by the temporary test VM.

This caused SSH warnings such as:

`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`

### Likely Cause

The cloned VMs likely shared machine identity or DHCP client identity from the original template. Possible causes include:

- Preserved `/etc/machine-id`
- Preserved cloud-init state
- DHCP lease behavior
- DHCP client identifier reuse

### Checks Performed

Checked that each VM had a unique MAC address:

```bash
qm config 201 | grep net0
qm config 202 | grep net0
qm config 203 | grep net0
```

Checked cloud-init IP configuration:

```bash
qm config 201 | grep ipconfig0
qm config 202 | grep ipconfig0
qm config 203 | grep ipconfig0
```

### Resolution

For Kubernetes nodes, switched from DHCP to static IP addressing through Proxmox cloud-init.

Assigned the following IP addresses:
| VM ID	| Hostname | IP Address |
|---|---|---|
| 201 | k8s-cp-0 | 10.10.10.201 |
| 202 | k8s-worker-01 | 10.10.10.202 |
| 203 | k8s-worker-02 | 10.10.10.203 |

Gateway and DNS:
| Setting | Value |
|---|---|
| Gateway | 10.10.10.1 |
| DNS | 10.10.10.1 |

Commands used:

```bash
qm set 201 --ipconfig0 ip=10.10.10.201/24,gw=10.10.10.1
qm set 202 --ipconfig0 ip=10.10.10.202/24,gw=10.10.10.1
qm set 203 --ipconfig0 ip=10.10.10.203/24,gw=10.10.10.1

qm set 201 --nameserver 10.10.10.1
qm set 202 --nameserver 10.10.10.1
qm set 203 --nameserver 10.10.10.1

qm cloudinit update 201
qm cloudinit update 202
qm cloudinit update 203

qm start 201
qm start 202
qm start 203
```

Removed stale SSH known host entries from the workstation:

```bash
ssh-keygen -R 10.10.10.201
ssh-keygen -R 10.10.10.202
ssh-keygen -R 10.10.10.203
```

### Result

Each VM successfully received its intended static IP address:
| VM ID | Hostname | IP Address |
|---|---|---|
| 201 | k8s-cp-01 | 10.10.10.201 |
| 202 | k8s-worker-01 | 10.10.10.202 |
| 203 | k8s-worker-02 | 10.10.10.203 |

SSH access could then be retried using the corrected static IP addresses.

### Future Prevention

Before converting a VM to a reusable template, clean machine identity and cloud-init state:

```bash
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
cloud-init clean --logs
```

This should help future DHCP-based clones request unique leases instead of reusing the same DHCP identity.

## ImagePullBackOff During Deployment Update

### Problem

While testing Kubernetes troubleshooting, the application image tag was intentionally changed from a valid tag to an invalid tag.

Original valid image:

```text
nginx:stable
```

Broken image:

```text
nginx:not-a-real-tag
```

After applying the manifest, the new pods failed to start and entered an `ImagePullBackOff` state.

### Diagnosis

Checked pod status:

```bash
kubectl get pods -n devops-lab
```

Described the failing pod:

```bash
kubectl describe pod POD_NAME -n devops-lab
```

The pod events showed that Kubernetes could not pull the invalid image tag.

### Resolution

The image tag was corrected in the deployment manifest:

```yaml
image: nginx:stable
```

Then the manifest was reapplied:

```bash
kubectl apply -f kubernetes/apps/nginx-lab/deployment.yaml
```

Verified that the pods recovered:

```bash
kubectl get pods -n devops-lab -w
```

### Skills Practiced

- Identifying failed pod states

- Using `kubectl describe pod`

- Reading Kubernetes event messages

- Fixing a bad container image reference

- Reapplying a corrected manifest

- Watching rollout recovery

## GitHub Actions Validation Failure

### Problem

A CI validation failure was intentionally triggered to verify that the GitHub Actions workflow catches invalid Kubernetes manifests.

The Deployment API version was temporarily changed from:

```yaml
apiVersion: apps/v1
```

to:

```yaml
apiVersion: apps/v999
```

### Diagnosis

The GitHub Actions workflow failed during Kubernetes manifest validation.

The workflow rendered the Helm chart with:

```yaml
helm template nginx-lab kubernetes/charts/nginx-lab
```

Then validated the rendered manifests with:

```yaml
kubeconform \
  -strict \
  -summary \
  -ignore-missing-schemas \
  rendered/nginx-lab.yaml
```

The invalid API version caused validation to fail.

### Resolution

The Deployment API version was corrected back to:

```yaml
apiVersion: apps/v1
```

After committing and pushing the fix, the GitHub Actions workflow completed successfully.

### Skills Practiced
- Creating a test branch
- Triggering CI validation from a pull request
- Reading GitHub Actions failure logs
- Fixing invalid Kubernetes manifest configuration
- Verifying CI recovery after a fix

## Kubeconform Validation Was Initially Too Permissive

### Problem

During the first CI failure test, the Deployment API version was intentionally changed from:

```yaml
apiVersion: apps/v1
```

to:

```yaml
apiVersion: apps/v999
```

However, the GitHub Actions workflow still passed.

### Cause

The workflow used the following kubeconform flag:

```bash
-ignore-missing-schemas
```

Because apps/v999 did not match a known Kubernetes schema, kubeconform treated it as a missing schema and ignored it instead of failing the workflow.

### Resolution

The flag was removed from the validation command.

Original command:

```bash
kubeconform \
  -strict \
  -summary \
  -ignore-missing-schemas \
  rendered/nginx-lab.yaml
```

Updated command:

```bash
kubeconform \
  -strict \
  -summary \
  rendered/nginx-lab.yaml
```

After this change, invalid Kubernetes API versions are expected to fail CI validation.
