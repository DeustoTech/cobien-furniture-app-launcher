#!/bin/bash
set -e

if [ "${COBIEN_ALLOW_SYSTEM_PROVISIONING:-}" != "yes" ]; then
    echo "[ERROR] This script is blocked by default to prevent accidental execution on development machines."
    echo "[ERROR] Run it only on a target CoBien furniture device with COBIEN_ALLOW_SYSTEM_PROVISIONING=yes."
    exit 1
fi

############################################################
# CONFIGURATION
############################################################

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_HOME" ]; then
    echo "[ERROR] Unable to determine the target user and home directory."
    exit 1
fi

USER_NAME="$TARGET_USER"
USER_HOME="$TARGET_HOME"

PROJECT_DIR="$USER_HOME/cobien"

FRONTEND_REPO="git@github.com:DeustoTech/cobien_FrontEnd.git"
MQTT_REPO="git@github.com:DeustoTech/cobien_MQTT_Dictionnary.git"

BRANCH_NAME="development_fix"

DISPLAY_OUTPUT="eDP-1"
DISPLAY_MODE="1920x1200"

echo "[INFO] Target user: $USER_NAME"
echo "[INFO] Target home: $USER_HOME"

############################################################
# INSTALL SYSTEM PACKAGES
############################################################

echo "[INFO] Installing required packages..."

sudo apt update
sudo apt install -y \
  git \
  openbox \
  lightdm \
  tint2 \
  xterm \
  x11-xserver-utils \
  wmctrl \
  pipewire \
  wireplumber \
  openssh-server

############################################################
# CREATE PROJECT DIRECTORY
############################################################

echo "[INFO] Creating project directory..."

mkdir -p "$PROJECT_DIR"

############################################################
# CLONE OR UPDATE REPOSITORIES
############################################################

echo "[INFO] Cloning repositories into $PROJECT_DIR..."

cd "$PROJECT_DIR"

if [ ! -d "$PROJECT_DIR/cobien_FrontEnd" ]; then
    git clone --branch "$BRANCH_NAME" --single-branch --depth 1 "$FRONTEND_REPO"
else
    echo "[INFO] Repository cobien_FrontEnd already exists. Updating..."
    cd "$PROJECT_DIR/cobien_FrontEnd"
    git fetch origin "$BRANCH_NAME" --depth 1
    git checkout "$BRANCH_NAME"
    git pull origin "$BRANCH_NAME"
    cd "$PROJECT_DIR"
fi

if [ ! -d "$PROJECT_DIR/cobien_MQTT_Dictionnary" ]; then
    git clone --branch "$BRANCH_NAME" --single-branch --depth 1 "$MQTT_REPO"
else
    echo "[INFO] Repository cobien_MQTT_Dictionnary already exists. Updating..."
    cd "$PROJECT_DIR/cobien_MQTT_Dictionnary"
    git fetch origin "$BRANCH_NAME" --depth 1
    git checkout "$BRANCH_NAME"
    git pull origin "$BRANCH_NAME"
    cd "$PROJECT_DIR"
fi

############################################################
# ENABLE SSH
############################################################

echo "[INFO] Enabling SSH..."

sudo systemctl enable ssh
sudo systemctl start ssh || true

############################################################
# CONFIGURE LIGHTDM AUTOLOGIN
############################################################

echo "[INFO] Configuring LightDM autologin into Openbox..."

sudo systemctl disable gdm3 2>/dev/null || true
sudo systemctl disable sddm 2>/dev/null || true
sudo systemctl enable lightdm

sudo mkdir -p /etc/lightdm/lightdm.conf.d

sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf > /dev/null <<EOF
[Seat:*]
autologin-user=$USER_NAME
autologin-session=openbox
EOF

############################################################
# CREATE REMOTE STARTUP SCRIPT
############################################################

echo "[INFO] Creating remote startup script..."

cat > "$USER_HOME/start-remote.sh" <<EOF
#!/bin/bash

sleep 5

export DISPLAY=:0
export XAUTHORITY=$USER_HOME/.Xauthority

# Set screen resolution
xrandr --output $DISPLAY_OUTPUT --mode $DISPLAY_MODE || true

# Start audio services if needed
pgrep -u "$USER_NAME" pipewire >/dev/null || pipewire &
pgrep -u "$USER_NAME" wireplumber >/dev/null || wireplumber &

# Start panel with system tray
pgrep -u "$USER_NAME" tint2 >/dev/null || tint2 &

# Keep RustDesk alive in tray/background mode
while true; do
    /usr/bin/rustdesk --tray >/tmp/rustdesk-openbox.log 2>&1 &
    sleep 4

    # Hide RustDesk window if it appears
    wmctrl -r "RustDesk" -b add,hidden 2>/dev/null || true

    wait \$!
    sleep 2
done
EOF

chmod +x "$USER_HOME/start-remote.sh"

############################################################
# CONFIGURE OPENBOX AUTOSTART
############################################################

echo "[INFO] Configuring Openbox autostart..."

mkdir -p "$USER_HOME/.config/openbox"

cat > "$USER_HOME/.config/openbox/autostart" <<EOF
#!/bin/bash

$USER_HOME/start-remote.sh &
EOF

chmod +x "$USER_HOME/.config/openbox/autostart"

############################################################
# VALIDATION
############################################################

echo "[INFO] Validating Openbox session..."

if [ ! -f /usr/share/xsessions/openbox.desktop ]; then
    echo "[ERROR] Openbox session file not found: /usr/share/xsessions/openbox.desktop"
    exit 1
fi

############################################################
# OPTIONAL SAFE CLEANUP
############################################################

echo "[INFO] Checking removable packages..."

if apt -s autoremove | grep -q "Remv"; then
    echo "[INFO] Running apt autoremove..."
    sudo apt autoremove -y
else
    echo "[INFO] No packages to autoremove."
fi

############################################################
# FINAL MESSAGE
############################################################

echo ""
echo "=================================================="
echo " Setup completed successfully"
echo "=================================================="
echo ""
echo "Project directory:"
echo "  $PROJECT_DIR"
echo ""
echo "Repositories:"
echo "  $PROJECT_DIR/cobien_FrontEnd"
echo "  $PROJECT_DIR/cobien_MQTT_Dictionnary"
echo ""
echo "Before rebooting, make sure RustDesk is installed and unattended access is configured."
echo ""
echo "Then reboot with:"
echo "  sudo reboot"
echo ""