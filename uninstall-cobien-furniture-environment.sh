#!/usr/bin/env bash
#
# CoBien Furniture Environment Uninstaller
#
# This script completely reverts the changes made by the setup script,
# restoring the system to a standard Ubuntu graphical desktop state (GNOME / GDM3).
#

set -euo pipefail

# Resolve the target furniture user account.
TARGET_USER="${COBIEN_SETUP_USER:-${SUDO_USER:-}}"
if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
    TARGET_USER="$(logname 2>/dev/null || true)"
fi
if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
    TARGET_USER="${USER:-}"
fi
if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
    echo "[ERROR] Could not determine the furniture user account."
    exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ]; then
    echo "[ERROR] User '${TARGET_USER}' does not exist or has no home directory."
    exit 1
fi

NON_INTERACTIVE="${COBIEN_NON_INTERACTIVE:-0}"
AUTO_CONFIRM="${COBIEN_AUTO_CONFIRM:-0}"
AUTO_REBOOT_AFTER_UNINSTALL="${COBIEN_AUTO_REBOOT_AFTER_UNINSTALL:-1}"

COLOR_RESET=""
COLOR_BOLD=""
COLOR_DIM=""
COLOR_BLUE=""
COLOR_CYAN=""
COLOR_GREEN=""
COLOR_YELLOW=""
COLOR_RED=""
COLOR_MAGENTA=""
COLOR_ACCENT=""

CURRENT_PHASE="bootstrap"
STEP_INDEX=0
STEP_TOTAL=5

init_colors() {
    if [[ -t 1 && "${NO_COLOR:-0}" != "1" ]]; then
        COLOR_RESET=$'\033[0m'
        COLOR_BOLD=$'\033[1m'
        COLOR_DIM=$'\033[2m'
        COLOR_BLUE=$'\033[34m'
        COLOR_CYAN=$'\033[36m'
        COLOR_GREEN=$'\033[32m'
        COLOR_YELLOW=$'\033[33m'
        COLOR_RED=$'\033[31m'
        COLOR_MAGENTA=$'\033[35m'
        COLOR_ACCENT=$'\033[35m'
    fi
}

print_header() {
    clear 2>/dev/null || true
    print_rule
    printf '%b%s%b\n' "${COLOR_BOLD}${COLOR_BLUE}" "CoBien Furniture Environment Uninstaller" "${COLOR_RESET}"
    print_rule
    echo "This script will restore your machine back to a clean Ubuntu desktop."
    echo "  - Reverts autologin and desktop session back to GNOME (GDM3)"
    echo "  - Stops and disables all CoBien background services"
    echo "  - Cleans up Openbox, dunst, and volume configs from target user"
    echo "  - Target User: ${TARGET_USER} (${TARGET_HOME})"
    print_rule
    echo
}

print_rule() {
    printf '%b%s%b\n' "$COLOR_DIM" "────────────────────────────────────────────────────────────" "$COLOR_RESET"
}

log() {
    local level="$1"
    shift
    local color="$COLOR_CYAN"
    case "$level" in
        INFO) color="$COLOR_CYAN" ;;
        OK) color="$COLOR_GREEN" ;;
        WARN) color="$COLOR_YELLOW" ;;
        ERROR) color="$COLOR_RED" ;;
        STEP) color="$COLOR_MAGENTA" ;;
    esac
    printf '%b[%s]%b %s\n' "$color" "$level" "$COLOR_RESET" "$*"
}

phase() {
    CURRENT_PHASE="$1"
    STEP_INDEX=$((STEP_INDEX + 1))
    echo
    print_rule
    printf '%bStep %d/%d%b %b%s%b\n' \
        "$COLOR_BOLD$COLOR_ACCENT" "$STEP_INDEX" "$STEP_TOTAL" "$COLOR_RESET" \
        "$COLOR_BOLD$COLOR_MAGENTA" "$1" "$COLOR_RESET"
    if [[ -n "${2:-}" ]]; then
        printf '%b%s%b\n' "$COLOR_DIM" "$2" "$COLOR_RESET"
    fi
    print_rule
}

print_status_badge() {
    local status="$1"
    local text="$2"
    local badge_color="$COLOR_GREEN"
    if [[ "$status" == "WARN" ]]; then
        badge_color="$COLOR_YELLOW"
    elif [[ "$status" == "ERROR" ]]; then
        badge_color="$COLOR_RED"
    elif [[ "$status" == "INFO" ]]; then
        badge_color="$COLOR_CYAN"
    fi
    printf '%b[%s]%b %s\n' "$badge_color" "$status" "$COLOR_RESET" "$text"
}

confirm() {
    local prompt="$1"
    if [[ "$AUTO_CONFIRM" == "1" || "$NON_INTERACTIVE" == "1" ]]; then
        return 0
    fi
    while true; do
        read -rp "$prompt [y/N]: " yn
        case "${yn:-N}" in
            [Yy]* ) return 0 ;;
            [Nn]*|* ) return 1 ;;
        esac
    done
}

run_cmd() {
    local desc="$1"
    shift
    log INFO "$desc..."
    if "$@"; then
        print_status_badge OK "$desc completed successfully"
        return 0
    else
        print_status_badge ERROR "$desc failed"
        return 1
    fi
}

_systemctl_user() {
    # Runs systemctl user commands as the target user.
    if [[ $EUID -eq 0 ]]; then
        sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$TARGET_USER")/bus" systemctl --user "$@" 2>/dev/null || \
        sudo -u "$TARGET_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$TARGET_USER")" systemctl --user "$@"
    else
        systemctl --user "$@"
    fi
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log ERROR "This script must be run as root/sudo. Re-running with sudo..."
        exec sudo COBIEN_SETUP_USER="$TARGET_USER" bash "$0" "$@"
    fi
}

# --- UNINSTALLATION STEPS ---

main() {
    init_colors
    check_root "$@"
    print_header

    if ! confirm "Are you sure you want to completely uninstall the CoBien environment?"; then
        log WARN "Uninstallation cancelled by the user."
        exit 0
    fi

    # Step 1: Stop and disable background services
    phase "Stopping and disabling CoBien services" "Stopping and removing systemd user services."
    
    # Enable user lingering check so we can communicate with user systemd daemon
    if command -v loginctl >/dev/null 2>&1; then
        loginctl enable-linger "$TARGET_USER" || true
    fi

    local services=(
        cobien-launcher.service
        cobien-update.service
        cobien-volume.service
    )
    local timers=(
        cobien-update.timer
    )

    for timer in "${timers[@]}"; do
        _systemctl_user stop "$timer" 2>/dev/null || true
        _systemctl_user disable "$timer" 2>/dev/null || true
    done

    for svc in "${services[@]}"; do
        _systemctl_user stop "$svc" 2>/dev/null || true
        _systemctl_user disable "$svc" 2>/dev/null || true
    done

    # Clean up user unit files
    local systemd_user_dir="$TARGET_HOME/.config/systemd/user"
    if [[ -d "$systemd_user_dir" ]]; then
        run_cmd "Cleaning up user systemd configurations" rm -f \
            "$systemd_user_dir/cobien-launcher.service" \
            "$systemd_user_dir/cobien-update.service" \
            "$systemd_user_dir/cobien-update.timer" \
            "$systemd_user_dir/cobien-volume.service" \
            "$systemd_user_dir/timers.target.wants/cobien-update.timer" \
            "$systemd_user_dir/default.target.wants/cobien-launcher.service"
        _systemctl_user daemon-reload || true
    fi

    # Stop and remove Mosquitto Docker container to release active folder mounts
    if command -v docker >/dev/null 2>&1; then
        run_cmd "Stopping local Mosquitto MQTT container" sudo docker stop cobien-mosquitto 2>/dev/null || true
        run_cmd "Removing local Mosquitto MQTT container" sudo docker rm cobien-mosquitto 2>/dev/null || true
    fi

    # Step 2: Clean up configuration folders
    phase "Removing CoBien user configurations" "Cleaning up Openbox, Dunst, xbindkeys, and helper scripts."
    
    run_cmd "Removing user config folders" rm -rf \
        "$TARGET_HOME/.config/openbox" \
        "$TARGET_HOME/.config/cobien" \
        "$TARGET_HOME/.config/dunst" \
        "$TARGET_HOME/.config/autostart/cobien-import-env.desktop" \
        "$TARGET_HOME/.xbindkeysrc"

    # Step 3: Restore Display Manager (GDM3/GNOME)
    phase "Restoring GNOME / GDM3 display manager" "Re-enabling GDM3 and disabling LightDM autologin."
    
    # Remove autologin configuration of LightDM
    rm -f /etc/lightdm/lightdm.conf.d/50-autologin.conf 2>/dev/null || true
    
    # Remove user from nopasswdlogin group
    if getent group nopasswdlogin >/dev/null 2>&1; then
        gpasswd -d "$TARGET_USER" nopasswdlogin 2>/dev/null || true
    fi

    # Detect if GDM3 or GDM is installed, and restore it
    local display_manager="/usr/sbin/gdm3"
    if [[ ! -x "$display_manager" && -x "/usr/sbin/gdm" ]]; then
        display_manager="/usr/sbin/gdm"
    fi

    if [[ -x "$display_manager" ]]; then
        run_cmd "Restoring GDM config" echo "$display_manager" | tee /etc/X11/default-display-manager >/dev/null
        run_cmd "Re-enabling GDM3 systemd service" systemctl enable --force "$(basename "$display_manager")"
        run_cmd "Restoring display-manager symlink to GDM3" ln -sfn "/lib/systemd/system/$(basename "$display_manager").service" /etc/systemd/system/display-manager.service
    else
        log WARN "GDM3 display manager not found. Please reconfigure your default display manager manually."
    fi

    run_cmd "Disabling LightDM" systemctl disable lightdm 2>/dev/null || true
    run_cmd "Setting default target to graphical" systemctl set-default graphical.target

    # Step 4: Restoring system configs (cloud-init, sleep targets)
    phase "Restoring system defaults" "Re-enabling system sleep/suspend targets and cloud-init."
    
    # Remove logind dock settings override if present
    rm -f /etc/systemd/logind.conf.d/50-cobien-kiosk.conf 2>/dev/null || true
    systemctl restart systemd-logind >/dev/null 2>&1 || true

    # Unmask system sleep/suspend targets
    systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null 2>&1 || true

    # Remove cloud-init disable marker
    rm -f /etc/cloud/cloud-init.disabled 2>/dev/null || true
    
    # Unmask cloud-init services
    local _ci_units=(
        cloud-init-main.service
        cloud-init-network.service
        cloud-init-local.service
        cloud-config.service
        cloud-final.service
        cloud-init.service
    )
    for _unit in "${_ci_units[@]}"; do
        systemctl unmask "$_unit" 2>/dev/null || true
    done

    # Step 5: Clean workspace (Optional)
    phase "Cleaning CoBien workspace" "Optional cleanup of repositories and workspace."
    if confirm "Do you want to completely delete the workspace directory ($TARGET_HOME/cobien) and its repositories?"; then
        run_cmd "Deleting workspace and repositories" rm -rf "$TARGET_HOME/cobien" "$TARGET_HOME/cobien.env"
    fi

    echo
    print_rule
    printf '%b%s%b\n' "$COLOR_BOLD$COLOR_GREEN" "Uninstallation Completed Successfully." "$COLOR_RESET"
    echo "The system is now restored to standard Ubuntu Desktop (GNOME / GDM3)."
    echo "A reboot is recommended to activate the GNOME graphical session."
    print_rule
    echo

    if [[ "$AUTO_REBOOT_AFTER_UNINSTALL" == "1" ]]; then
        if confirm "Do you want to reboot the system now?"; then
            log INFO "Rebooting..."
            reboot
        fi
    fi
}

main "$@"
