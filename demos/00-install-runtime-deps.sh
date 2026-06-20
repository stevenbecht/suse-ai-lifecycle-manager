#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "${SCRIPT_DIR}/common.sh"

K3S_SELINUX_RPM_URL="${K3S_SELINUX_RPM_URL:-https://rpm.rancher.io/k3s/stable/common/microos/noarch/k3s-selinux-1.6-1.sle.noarch.rpm}"
K3S_SELINUX_RPM_PATH="${K3S_SELINUX_RPM_PATH:-${SCRIPT_DIR}/$(basename "${K3S_SELINUX_RPM_URL}")}"

os_id=""
os_like=""
os_pretty="unknown OS"
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  os_id="${ID:-}"
  os_like="${ID_LIKE:-}"
  os_pretty="${PRETTY_NAME:-${ID:-unknown OS}}"
fi

case " ${os_id} ${os_like} " in
  *opensuse*|*sles*|*suse*) ;;
  *)
    log "no known ${INSTALL_RUNTIME} dependency step for ${os_pretty}; skipping"
    log "warning: ${INSTALL_RUNTIME} install may still need OS-specific dependencies"
    exit 0
    ;;
esac

need sudo
need zypper

if [[ "${INSTALL_RUNTIME}" == "rke2" ]]; then
  log "installing SUSE RKE2 dependency: apparmor-parser"
  sudo zypper --non-interactive install -y apparmor-parser
  exit 0
fi

need curl
need rpm

log "installing SUSE k3s dependency: container-selinux"
sudo zypper --non-interactive install -y container-selinux

if rpm -q k3s-selinux >/dev/null 2>&1; then
  log "k3s-selinux is already installed"
  exit 0
fi

log "downloading k3s-selinux policy RPM"
curl -fL -o "${K3S_SELINUX_RPM_PATH}" "${K3S_SELINUX_RPM_URL}"

log "installing k3s-selinux policy RPM"
sudo rpm -ivh "${K3S_SELINUX_RPM_PATH}"
