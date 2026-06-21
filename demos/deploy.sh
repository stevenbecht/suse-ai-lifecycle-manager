#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="${SCRIPT_DIR}/scripts"

steps=(
  "00-install-runtime-deps.sh"
  "01-install-runtime.sh"
  "02-install-rancher-deps.sh"
  "03-install-rancher.sh"
  "04-install-aif-operator.sh"
)

for step in "${steps[@]}"; do
  printf '>>> running scripts/%s\n' "${step}"
  "${STEPS_DIR}/${step}"
done
