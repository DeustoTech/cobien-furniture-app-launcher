#!/usr/bin/env bash
set -euo pipefail

VARS=(
  DISPLAY
  XAUTHORITY
  DBUS_SESSION_BUS_ADDRESS
  XDG_CURRENT_DESKTOP
  XDG_SESSION_TYPE
  DESKTOP_SESSION
  WAYLAND_DISPLAY
)

SESSION_NAME="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-unknown}}"

printf '[COBIEN] Importing graphical session environment for systemd --user (%s)\n' "$SESSION_NAME"

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
  dbus-update-activation-environment --systemd "${VARS[@]}" >/dev/null 2>&1 || true
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user import-environment "${VARS[@]}" >/dev/null 2>&1 || true
  if systemctl --user is-enabled --quiet cobien-launcher.service >/dev/null 2>&1; then
    printf '[COBIEN] Restarting cobien-launcher.service with imported session environment\n'
    systemctl --user restart cobien-launcher.service >/dev/null 2>&1 || true
  fi
fi

exit 0
