#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${COBIEN_ALLOW_SYSTEM_PROVISIONING:-}" != "yes" ]; then
    echo "[ERROR] This script is blocked by default to prevent accidental execution on development machines."
    echo "[ERROR] Run it only on a target CoBien furniture device with COBIEN_ALLOW_SYSTEM_PROVISIONING=yes."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [ -z "$TARGET_USER" ] || [ -z "$TARGET_HOME" ]; then
    echo "[ERROR] Unable to determine the target user and home directory."
    exit 1
fi

USER_NAME="$TARGET_USER"
USER_HOME="$TARGET_HOME"

PROJECT_DIR="${COBIEN_WORKSPACE_ROOT:-$USER_HOME/cobien}"
FRONTEND_REPO_NAME="${COBIEN_FRONTEND_REPO_NAME:-cobien_FrontEnd}"
MQTT_REPO_NAME="${COBIEN_MQTT_REPO_NAME:-cobien_MQTT_Dictionnary}"
BRANCH_NAME="${COBIEN_UPDATE_BRANCH:-master}"
DISPLAY_OUTPUT="${COBIEN_DISPLAY_OUTPUT:-eDP-1}"
DISPLAY_MODE="${COBIEN_DISPLAY_MODE:-1920x1200}"
NON_INTERACTIVE="${COBIEN_NON_INTERACTIVE:-0}"
AUTO_CONFIRM="${COBIEN_AUTO_CONFIRM:-0}"
RUN_LAUNCHER_AFTER_SETUP="${COBIEN_RUN_LAUNCHER_AFTER_SETUP:-1}"
MASTER_ENV_FILE="${COBIEN_MASTER_ENV_FILE:-}"

FRONTEND_REPO="git@github.com:DeustoTech/${FRONTEND_REPO_NAME}.git"
MQTT_REPO="git@github.com:DeustoTech/${MQTT_REPO_NAME}.git"

COLOR_RESET=""
COLOR_BOLD=""
COLOR_DIM=""
COLOR_BLUE=""
COLOR_CYAN=""
COLOR_GREEN=""
COLOR_YELLOW=""
COLOR_RED=""
COLOR_MAGENTA=""
COLOR_WHITE=""
COLOR_BG=""
COLOR_ACCENT=""

CURRENT_PHASE="bootstrap"
STEP_INDEX=0
STEP_TOTAL=7
LAUNCHER_EXECUTED=0
LAUNCHER_EXIT_CODE=0

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
        COLOR_WHITE=$'\033[37m'
        COLOR_BG=$'\033[48;5;255m'
        COLOR_ACCENT=$'\033[38;5;33m'
    fi
}

print_banner() {
    cat <<EOF
${COLOR_BOLD}${COLOR_CYAN}
   ______      ____  _           
  / ____/___  / __ )(_)__  ____ _
 / /   / __ \/ __  / / _ \/ __ '/
/ /___/ /_/ / /_/ / /  __/ /_/ / 
\____/\____/_____/_/\___/\__,_/  
${COLOR_RESET}
${COLOR_BOLD}${COLOR_BLUE}Furniture Environment Setup${COLOR_RESET}
EOF
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

animate() {
    local message="$1"
    local dots="${2:-3}"
    local i
    printf '%b[....]%b %s' "$COLOR_BLUE" "$COLOR_RESET" "$message"
    if [[ -t 1 && "$NON_INTERACTIVE" != "1" ]]; then
        for ((i = 0; i < dots; i++)); do
            printf '.'
            sleep 0.12
        done
    else
        printf '...'
    fi
    printf '\n'
}

print_status_badge() {
    local status="$1"
    local label="$2"
    local color="$COLOR_CYAN"
    case "$status" in
        OK) color="$COLOR_GREEN" ;;
        WARN) color="$COLOR_YELLOW" ;;
        ERROR) color="$COLOR_RED" ;;
        INFO) color="$COLOR_CYAN" ;;
    esac
    printf '%b[%s]%b %s\n' "$color" "$status" "$COLOR_RESET" "$label"
}

print_kv() {
    local key="$1"
    local value="$2"
    printf '  %-22s %s\n' "$key" "$value"
}

print_intro_panel() {
    echo
    printf '%b%s%b\n' "$COLOR_BOLD$COLOR_WHITE" "Deployment assistant for CoBien furniture devices" "$COLOR_RESET"
    echo "This guided setup prepares the operating system, configures the desktop session,"
    echo "syncs the required repositories and can continue directly into the furniture launcher."
    echo
    print_status_badge INFO "Target user detected automatically"
    print_status_badge INFO "Desktop session will be prepared for Openbox + LightDM"
    print_status_badge INFO "Repositories will be synced on branch ${BRANCH_NAME}"
    if [[ -n "$MASTER_ENV_FILE" ]]; then
        print_status_badge OK "Deployment env preselected: ${MASTER_ENV_FILE}"
    else
        print_status_badge WARN "No deployment env was passed yet; the launcher will use its normal discovery flow"
    fi
    echo
}

print_preflight_snapshot() {
    printf '%b%s%b\n' "$COLOR_BOLD" "Preflight snapshot" "$COLOR_RESET"
    print_kv "User" "$USER_NAME"
    print_kv "Home" "$USER_HOME"
    print_kv "Workspace" "$PROJECT_DIR"
    print_kv "Branch" "$BRANCH_NAME"
    print_kv "Frontend repo" "$FRONTEND_REPO_NAME"
    print_kv "MQTT repo" "$MQTT_REPO_NAME"
    print_kv "Display output" "$DISPLAY_OUTPUT"
    print_kv "Display mode" "$DISPLAY_MODE"
    print_kv "Deployment env" "${MASTER_ENV_FILE:-auto-discovered later}"
    echo
}

add_env_candidate() {
    local candidate="$1"
    [[ -z "$candidate" ]] && return 0
    [[ -f "$candidate" ]] || return 0
    case " ${ENV_CANDIDATES[*]:-} " in
        *" $candidate "*) ;;
        *) ENV_CANDIDATES+=("$candidate") ;;
    esac
}

discover_env_candidates() {
    ENV_CANDIDATES=()

    add_env_candidate "$MASTER_ENV_FILE"
    add_env_candidate "$SCRIPT_DIR/cobien.env"
    add_env_candidate "$PARENT_DIR/env_for_furnitures/cobien.env"

    local pattern
    for pattern in \
        "$PARENT_DIR"/env_for_furnitures/cobien.env.* \
        "$PARENT_DIR"/env_for_furnitures/cobien.env.CoBien* \
        "$USER_HOME"/cobien.env \
        "$USER_HOME"/cobien/cobien.env
    do
        add_env_candidate "$pattern"
    done
}

choose_master_env_file() {
    discover_env_candidates

    if [[ -n "$MASTER_ENV_FILE" && -f "$MASTER_ENV_FILE" ]]; then
        return 0
    fi

    if [[ ${#ENV_CANDIDATES[@]} -eq 0 ]]; then
        log WARN "No deployment env candidates were found automatically."
        return 0
    fi

    if [[ "$NON_INTERACTIVE" == "1" || "$AUTO_CONFIRM" == "1" ]]; then
        MASTER_ENV_FILE="${ENV_CANDIDATES[0]}"
        log INFO "Using deployment env automatically: $MASTER_ENV_FILE"
        return 0
    fi

    echo
    printf '%b%s%b\n' "$COLOR_BOLD" "Detected deployment env candidates" "$COLOR_RESET"
    local i=1
    local candidate
    for candidate in "${ENV_CANDIDATES[@]}"; do
        printf '  %d. %s\n' "$i" "$candidate"
        i=$((i + 1))
    done
    echo "  0. Continue without preselecting a deployment env"
    echo

    while true; do
        printf '%b[SELECT]%b Choose the deployment env to use [0-%d]: ' \
            "$COLOR_YELLOW" "$COLOR_RESET" "${#ENV_CANDIDATES[@]}"
        read -r selection
        if [[ "$selection" == "0" || -z "$selection" ]]; then
            MASTER_ENV_FILE=""
            return 0
        fi
        if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#ENV_CANDIDATES[@]} )); then
            MASTER_ENV_FILE="${ENV_CANDIDATES[$((selection - 1))]}"
            log OK "Selected deployment env: $MASTER_ENV_FILE"
            return 0
        fi
    done
}

preflight_checks() {
    local missing=0
    print_status_badge INFO "Running local preflight checks"

    if command -v git >/dev/null 2>&1; then
        print_status_badge OK "git is available"
    else
        print_status_badge ERROR "git is missing"
        missing=1
    fi

    if command -v sudo >/dev/null 2>&1; then
        print_status_badge OK "sudo is available"
    else
        print_status_badge ERROR "sudo is missing"
        missing=1
    fi

    if [[ -x "$SCRIPT_DIR/cobien-launcher.sh" ]]; then
        print_status_badge OK "cobien-launcher.sh is present"
    else
        print_status_badge ERROR "cobien-launcher.sh is missing"
        missing=1
    fi

    if [[ -n "$MASTER_ENV_FILE" ]]; then
        if [[ -f "$MASTER_ENV_FILE" ]]; then
            print_status_badge OK "Deployment env is reachable"
        else
            print_status_badge ERROR "Deployment env is not reachable"
            missing=1
        fi
    else
        print_status_badge WARN "No deployment env selected yet"
    fi

    return "$missing"
}

confirm() {
    local prompt="$1"
    if [[ "$NON_INTERACTIVE" == "1" || "$AUTO_CONFIRM" == "1" ]]; then
        return 0
    fi
    while true; do
        printf '%b[CONFIRM]%b %s [y/N]: ' "$COLOR_YELLOW" "$COLOR_RESET" "$prompt"
        read -r answer
        case "${answer,,}" in
            y|yes) return 0 ;;
            n|no|"") return 1 ;;
        esac
    done
}

run_cmd() {
    local description="$1"
    shift
    animate "$description"
    "$@"
}

ensure_repo() {
    local repo_dir="$1"
    local repo_url="$2"
    local repo_label="$3"

    if [ ! -d "$repo_dir/.git" ]; then
        run_cmd "Cloning ${repo_label} into $(basename "$repo_dir")" \
            git clone --branch "$BRANCH_NAME" --single-branch "$repo_url" "$repo_dir"
    else
        phase "Syncing ${repo_label}" "Refreshing the existing checkout on branch ${BRANCH_NAME}."
        (
            cd "$repo_dir"
            run_cmd "Fetching ${repo_label}" git fetch origin "$BRANCH_NAME"
            run_cmd "Checking out ${BRANCH_NAME}" git checkout "$BRANCH_NAME"
            run_cmd "Pulling latest ${repo_label}" git pull origin "$BRANCH_NAME"
        )
    fi
}

write_openbox_autostart() {
    mkdir -p "$USER_HOME/.config/openbox"

    cat > "$USER_HOME/.config/openbox/autostart" <<EOF
#!/usr/bin/env bash

sleep 2
xrandr --output ${DISPLAY_OUTPUT} --mode ${DISPLAY_MODE} >/dev/null 2>&1 || true

pgrep -u "${USER_NAME}" pipewire >/dev/null || pipewire >/tmp/cobien-pipewire.log 2>&1 &
pgrep -u "${USER_NAME}" wireplumber >/dev/null || wireplumber >/tmp/cobien-wireplumber.log 2>&1 &

if [ -x "${SCRIPT_DIR}/import-systemd-user-env.sh" ]; then
  "${SCRIPT_DIR}/import-systemd-user-env.sh" >/tmp/cobien-import-session-env.log 2>&1 || true
fi
EOF

    chmod +x "$USER_HOME/.config/openbox/autostart"
}

write_lightdm_config() {
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf > /dev/null <<EOF
[Seat:*]
autologin-user=${USER_NAME}
autologin-session=openbox
EOF
}

disable_other_display_managers() {
    sudo systemctl disable gdm3 2>/dev/null || true
    sudo systemctl disable sddm 2>/dev/null || true
}

print_summary() {
    echo
    print_rule
    printf '%b%s%b\n' "$COLOR_BOLD$COLOR_GREEN" "Setup completed successfully" "$COLOR_RESET"
    print_rule
    echo
    print_status_badge OK "System packages installed"
    print_status_badge OK "Workspace prepared"
    print_status_badge OK "Repositories synchronized"
    print_status_badge OK "Desktop session configured"
    print_status_badge OK "Openbox session validated"
    echo
    print_kv "Target user" "$USER_NAME"
    print_kv "Target home" "$USER_HOME"
    print_kv "Workspace" "$PROJECT_DIR"
    print_kv "Branch" "$BRANCH_NAME"
    print_kv "Frontend repo" "$PROJECT_DIR/$FRONTEND_REPO_NAME"
    print_kv "MQTT repo" "$PROJECT_DIR/$MQTT_REPO_NAME"
    print_kv "Desktop session" "Openbox via LightDM autologin"
    print_kv "Deployment env" "${MASTER_ENV_FILE:-auto-discovered by launcher}"
    echo
}

on_error() {
    local exit_code="$1"
    local line_no="$2"
    echo
    log ERROR "Setup failed in phase '$CURRENT_PHASE' at line ${line_no} with exit code ${exit_code}."
    log ERROR "Target user: ${USER_NAME}"
    log ERROR "Workspace: ${PROJECT_DIR}"
    exit "$exit_code"
}

trap 'on_error $? $LINENO' ERR

main() {
    init_colors
    clear 2>/dev/null || true
    print_banner
    print_intro_panel
    choose_master_env_file
    print_preflight_snapshot

    if ! confirm "Continue with the full furniture environment setup?"; then
        log WARN "Setup cancelled by the user."
        exit 0
    fi

    phase "Checking prerequisites" "Verifying the installer tools and the selected deployment env before changing the system."
    if ! preflight_checks; then
        log ERROR "Preflight checks failed. Fix the missing items and run the setup again."
        exit 1
    fi

    phase "Installing system packages" "Openbox, LightDM, audio stack and display helpers will be installed."
    run_cmd "Updating apt metadata" sudo apt update
    run_cmd "Installing required packages" sudo apt install -y \
        git \
        openbox \
        lightdm \
        tint2 \
        xterm \
        x11-xserver-utils \
        wmctrl \
        pipewire \
        wireplumber

    phase "Preparing workspace" "The furniture repositories will live under the target workspace."
    run_cmd "Creating workspace directory" mkdir -p "$PROJECT_DIR"

    phase "Syncing repositories" "The production repositories will be cloned or updated on branch ${BRANCH_NAME}."
    ensure_repo "$PROJECT_DIR/$FRONTEND_REPO_NAME" "$FRONTEND_REPO" "frontend"
    ensure_repo "$PROJECT_DIR/$MQTT_REPO_NAME" "$MQTT_REPO" "mqtt dictionary"

    phase "Configuring the desktop session" "LightDM autologin and Openbox autostart will be prepared."
    run_cmd "Disabling other display managers if present" disable_other_display_managers
    run_cmd "Enabling LightDM" sudo systemctl enable lightdm
    run_cmd "Writing LightDM autologin" write_lightdm_config
    run_cmd "Writing Openbox autostart" write_openbox_autostart

    phase "Validating the graphical session" "Checking that the Openbox session entry is installed and ready."
    if [ ! -f /usr/share/xsessions/openbox.desktop ]; then
        log ERROR "Openbox session file not found: /usr/share/xsessions/openbox.desktop"
        exit 1
    fi
    log OK "Openbox session file detected."

    print_summary

    if [[ "$RUN_LAUNCHER_AFTER_SETUP" == "1" ]]; then
        phase "Handing off to the application launcher" "The base system is ready; the launcher can now complete the furniture deployment."
        if [[ -z "$MASTER_ENV_FILE" ]]; then
            log WARN "COBIEN_MASTER_ENV_FILE is not set. The launcher will use its normal discovery flow."
        else
            log INFO "Launcher will use: $MASTER_ENV_FILE"
        fi

        if confirm "Run cobien-launcher.sh now to continue the furniture deployment?"; then
            local launcher_cmd=("$SCRIPT_DIR/cobien-launcher.sh")
            if [[ "$NON_INTERACTIVE" == "1" ]]; then
                launcher_cmd+=(--non-interactive)
            fi
            if [[ "$AUTO_CONFIRM" == "1" ]]; then
                launcher_cmd+=(--yes)
            fi
            animate "Starting the CoBien launcher"
            LAUNCHER_EXECUTED=1
            if [[ -n "$MASTER_ENV_FILE" ]]; then
                COBIEN_MASTER_ENV_FILE="$MASTER_ENV_FILE" "${launcher_cmd[@]}"
                LAUNCHER_EXIT_CODE=$?
            else
                "${launcher_cmd[@]}"
                LAUNCHER_EXIT_CODE=$?
            fi
        else
            log INFO "Launcher step skipped for now."
        fi
    fi

    echo
    print_rule
    printf '%b%s%b\n' "$COLOR_BOLD$COLOR_BLUE" "Everything is ready." "$COLOR_RESET"
    if [[ "$LAUNCHER_EXECUTED" == "1" ]]; then
        if [[ "$LAUNCHER_EXIT_CODE" == "0" ]]; then
            print_status_badge OK "The launcher finished successfully during this guided setup"
        else
            print_status_badge WARN "The launcher was started but did not finish cleanly"
        fi
    else
        print_status_badge INFO "The base environment is ready; the application launcher has not been run yet"
        if [[ -n "$MASTER_ENV_FILE" ]]; then
            echo "To continue later:"
            echo "  COBIEN_MASTER_ENV_FILE=\"$MASTER_ENV_FILE\" \"$SCRIPT_DIR/cobien-launcher.sh\""
        else
            echo "To continue later:"
            echo "  \"$SCRIPT_DIR/cobien-launcher.sh\""
        fi
    fi
    echo "When you want the graphical session to be applied cleanly, reboot the furniture device."
    echo
    print_status_badge INFO "Suggested next command: sudo reboot"
    echo
}

main "$@"
