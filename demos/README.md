# autoaif

Demo automation for installing a local SUSE AI Lifecycle Manager environment.

This does more than install a Kubernetes runtime. The full flow installs:

- runtime OS dependencies
- a local RKE2 or k3s Kubernetes runtime
- Rancher dependencies, including cert-manager
- Rancher
- the AIF operator and UI extension

The scripts default to RKE2.

## Layout

- `deploy.sh`: top-level demo installer.
- `scripts/`: individual install steps and shared shell helpers.
- `uc/`: Elemental / UC image-building option for an RKE2 demo host.
- `blueprints/`: example blueprints to apply after AIF is installed.
- `docs/`: supporting demo documentation.

## Install Everything

From the repository root:

```bash
demos/deploy.sh
```

The scripts call `sudo` for privileged operations. Running them with `sudo` also
works; when invoked through `sudo`, `scripts/common.sh` targets the original
user's `~/.kube/config` instead of `/root/.kube/config`.

You can also run the steps individually:

```bash
demos/scripts/00-install-runtime-deps.sh
demos/scripts/01-install-runtime.sh
demos/scripts/02-install-rancher-deps.sh
demos/scripts/03-install-rancher.sh
demos/scripts/04-install-aif-operator.sh
```

## Use The Demo

After install, Rancher is available at the URL printed by
`demos/scripts/03-install-rancher.sh`, for example:

```text
Rancher URL: https://<host-ip>.sslip.io
```

Log in with:

```text
Username: admin
Password: password
```

The CLI is also configured. Source the shared environment in each new shell:

```bash
source demos/scripts/common.sh
kubectl get pods -A
```

Apply demo blueprints from the repository root:

```bash
kubectl apply -f demos/blueprints/blueprint-nginx.yaml
kubectl apply -f demos/blueprints/blueprint-open-webui-ollama.yaml
```

Or apply another blueprint in the same directory:

```bash
kubectl apply -f demos/blueprints/<blueprint-file>.yaml
```

## Current Shell

After installing the runtime, source the shared environment in each new shell:

```bash
source demos/scripts/common.sh
```

This adds the RKE2 binary path and makes `kubectl` use the runtime-managed
kubectl binary and the copied kubeconfig.

## Runtime Selection

Use k3s instead of RKE2 by setting `INSTALL_RUNTIME`:

```bash
export INSTALL_RUNTIME=k3s
demos/scripts/00-install-runtime-deps.sh
demos/scripts/01-install-runtime.sh
source demos/scripts/common.sh
```

## UC / Elemental Image Path

To build an immutable Elemental / UC image that boots into RKE2, see
`demos/uc/README.md`. That path produces an OS image first, then installs
Rancher and the AIF operator onto the resulting RKE2 cluster from a workstation
with `kubectl` and `helm`.

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
demos/scripts/01-install-runtime.sh
source demos/scripts/common.sh
kubectl get pods -A
```

If you need to repair it manually:

```bash
sudo install -d -m 700 -o "$(id -u)" -g "$(id -g)" "$HOME/.kube"
sudo install -m 600 -o "$(id -u)" -g "$(id -g)" /etc/rancher/rke2/rke2.yaml "$HOME/.kube/config"
source demos/scripts/common.sh
kubectl get pods -A
```
