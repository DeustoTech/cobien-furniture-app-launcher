#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_SRC_DIR="$SCRIPT_DIR/systemd"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
SYSTEMD_OVERRIDE_DIR="$SYSTEMD_USER_DIR/cobien-launcher.service.d"
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/cobien-import-session-env.desktop"
OPENBOX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/openbox"
OPENBOX_AUTOSTART_FILE="$OPENBOX_DIR/autostart"
OPENBOX_SENTINEL="# CoBien session env import"

mkdir -p "$SYSTEMD_USER_DIR"
mkdir -p "$AUTOSTART_DIR"
mkdir -p "$OPENBOX_DIR"

# Enable linger so user services survive without an active login session
if command -v loginctl >/dev/null 2>&1; then
  loginctl enable-linger "$USER" || true
  echo "[OK] Enabled linger for user: $USER"
fi

install -m 0644 "$SYSTEMD_SRC_DIR/cobien-launcher.service" "$SYSTEMD_USER_DIR/cobien-launcher.service"
install -m 0644 "$SYSTEMD_SRC_DIR/cobien-update.service" "$SYSTEMD_USER_DIR/cobien-update.service"
install -m 0644 "$SYSTEMD_SRC_DIR/cobien-update.timer" "$SYSTEMD_USER_DIR/cobien-update.timer"

rm -rf "$SYSTEMD_OVERRIDE_DIR"
echo "[OK] Removed legacy graphical override: $SYSTEMD_OVERRIDE_DIR"

cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=CoBien Session Env Import
Comment=Import GNOME/XFCE graphical environment into systemd user services
Exec=/bin/bash $SCRIPT_DIR/import-systemd-user-env.sh
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=2
X-XFCE-Autostart-enabled=true
X-MATE-Autostart-enabled=true
NoDisplay=true
Terminal=false
EOF
echo "[OK] Installed session env autostart helper: $AUTOSTART_FILE"

if [[ ! -f "$OPENBOX_AUTOSTART_FILE" ]]; then
  cat > "$OPENBOX_AUTOSTART_FILE" <<EOF
$OPENBOX_SENTINEL
/bin/bash $SCRIPT_DIR/import-systemd-user-env.sh &
EOF
  echo "[OK] Created Openbox autostart hook: $OPENBOX_AUTOSTART_FILE"
elif ! grep -Fq "$OPENBOX_SENTINEL" "$OPENBOX_AUTOSTART_FILE"; then
  printf '\n%s\n%s\n' "$OPENBOX_SENTINEL" "/bin/bash $SCRIPT_DIR/import-systemd-user-env.sh &" >> "$OPENBOX_AUTOSTART_FILE"
  echo "[OK] Appended Openbox autostart hook: $OPENBOX_AUTOSTART_FILE"
else
  echo "[OK] Openbox autostart hook already present: $OPENBOX_AUTOSTART_FILE"
fi

if crontab -l >/dev/null 2>&1; then
  crontab -l | grep -v 'cobien-launcher.sh --mode update-once' | crontab -
  echo "[OK] Removed legacy cron update-once entries (if any)"
fi

systemctl --user daemon-reload
systemctl --user enable --now cobien-launcher.service
systemctl --user enable --now cobien-update.timer
systemctl --user restart cobien-launcher.service

echo "[OK] Installed systemd user units in: $SYSTEMD_USER_DIR"
echo "[OK] Enabled: cobien-launcher.service"
echo "[OK] Enabled: cobien-update.timer"
echo "[OK] Session env helper: $AUTOSTART_FILE"
echo "[OK] Openbox hook: $OPENBOX_AUTOSTART_FILE"
echo
echo "Verification commands:"
echo "  systemctl --user status cobien-launcher.service"
echo "  systemctl --user list-timers | grep cobien-update"
echo "  journalctl --user -u cobien-launcher.service -f"
