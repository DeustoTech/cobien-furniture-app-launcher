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
  if systemctl --user is-enabled --quiet cobien-launcher.service 2>/dev/null; then
    if systemctl --user is-active --quiet cobien-launcher.service 2>/dev/null; then
      printf '[COBIEN] cobien-launcher.service already active; session environment updated\n'
    else
      # Clear any accumulated failure state from previous boots before starting.
      systemctl --user reset-failed cobien-launcher.service >/dev/null 2>&1 || true
      printf '[COBIEN] Starting cobien-launcher.service with imported session environment\n'
      systemctl --user start cobien-launcher.service >/dev/null 2>&1 || true
    fi
  fi
fi

exit 0
