#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[WARN] install-systemd-user.sh is now a compatibility wrapper."
echo "[WARN] The official CoBien entrypoint is setup-cobien-furniture-environment.sh."
echo "[INFO] Reusing cobien-launcher.sh to install and verify user services."

exec /bin/bash "$SCRIPT_DIR/cobien-launcher.sh" --mode setup --install-systemd-user --non-interactive --yes
