#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat >&2 <<EOF
[ERROR] install-systemd-user.sh is retired.
[ERROR] The launcher no longer provisions systemd units by itself.
[ERROR] Use the official device installer instead:
[ERROR]
[ERROR]   sudo COBIEN_ALLOW_SYSTEM_PROVISIONING=yes bash "$SCRIPT_DIR/setup-cobien-furniture-environment.sh"
[ERROR]
[ERROR] This is intentional: setup-cobien-furniture-environment.sh is the
[ERROR] single authority for system packages, desktop setup and systemd units.
EOF

exit 1
