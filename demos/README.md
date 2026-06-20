# autoaif

Scripts for installing a local RKE2 or k3s Kubernetes runtime, Rancher, cert-manager,
and the AIF operator.

## Default Runtime

The scripts default to RKE2:

```bash
./00-install-runtime-deps.sh
./01-install-runtime.sh
source ./common.sh
kubectl get pods -A
```

You can also run all steps:

```bash
./aio.sh
```

The scripts call `sudo` for privileged operations. Running them with `sudo` also
works; when invoked through `sudo`, `common.sh` targets the original user's
`~/.kube/config` instead of `/root/.kube/config`.

## Current Shell

After installing the runtime, source the shared environment in each new shell:

```bash
source ./common.sh
```

This adds the RKE2 binary path and makes `kubectl` use the runtime-managed
kubectl binary and the copied kubeconfig.

## Runtime Selection

Use k3s instead of RKE2 by setting `INSTALL_RUNTIME`:

```bash
export INSTALL_RUNTIME=k3s
./00-install-runtime-deps.sh
./01-install-runtime.sh
source ./common.sh
```

## Useful Overrides

- `KUBECONFIG_PATH`: destination kubeconfig path. Defaults to `~/.kube/config`,
  or the invoking sudo user's home when the scripts run through `sudo`.
- `RUNTIME_READY_TIMEOUT`: timeout for Kubernetes node readiness. Defaults to
  `300s`.
- `RANCHER_HOSTNAME`: Rancher hostname. Defaults to `<host-ip>.sslip.io`.
- `RANCHER_BOOTSTRAP_PASSWORD`: Rancher bootstrap password. Defaults to
  `password`.
- `RANCHER_BOOTSTRAP_COMPLETE`: complete Rancher's first-login setup
  non-interactively after install. Defaults to `true`. This sets the Rancher
  server URL, marks first login complete, and accepts the UI EULA prompt.
- `RANCHER_HELM_REPO_CHANNEL`: Rancher chart channel. Defaults to `stable`.
  Use `latest` when you specifically want the newest Rancher features.
- `RANCHER_CHART_VERSION`: optional Rancher chart version pin, for example
  `2.14.2`.
- `RANCHER_INGRESS_CLASS`: Rancher ingress class. Defaults to auto-detecting
  the runtime ingress class, usually `nginx` on current RKE2 or `traefik` on
  k3s/future RKE2.
- `RANCHER_INGRESS_READY_TIMEOUT`: seconds to wait for the runtime ingress
  controller before installing Rancher. Defaults to `300`.
- `AIF_CHART_VERSION`: AIF operator chart version. Defaults to `0.1.0-dev.1`.

## Recovering A Stale Kubeconfig

If `kubectl` fails with `x509: certificate signed by unknown authority` after an
RKE2 reinstall, refresh the user kubeconfig:

```bash
./01-install-runtime.sh
source ./common.sh
kubectl get pods -A
```

If you need to repair it manually:

```bash
sudo install -d -m 700 -o "$(id -u)" -g "$(id -g)" "$HOME/.kube"
sudo install -m 600 -o "$(id -u)" -g "$(id -g)" /etc/rancher/rke2/rke2.yaml "$HOME/.kube/config"
source ./common.sh
kubectl get pods -A
```
