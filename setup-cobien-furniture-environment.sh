#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

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
DISPLAY_ROTATION="${COBIEN_DISPLAY_ROTATION:-inverted}"
DISABLE_SYSTEM_SLEEP="${COBIEN_DISABLE_SYSTEM_SLEEP:-1}"
NON_INTERACTIVE="${COBIEN_NON_INTERACTIVE:-0}"
AUTO_CONFIRM="${COBIEN_AUTO_CONFIRM:-0}"
MASTER_ENV_FILE="${COBIEN_MASTER_ENV_FILE:-}"
FETCH_CONFIG_ONLINE="${COBIEN_FETCH_CONFIG_ONLINE:-0}"
ADMIN_BASE_URL="${COBIEN_ADMIN_BASE_URL:-https://portal.co-bien.eu}"
ADMIN_USERNAME="${COBIEN_ADMIN_USERNAME:-}"
ADMIN_PASSWORD="${COBIEN_ADMIN_PASSWORD:-}"
TARGET_DEVICE_ID="${COBIEN_TARGET_DEVICE_ID:-}"
INSTALL_RUSTDESK="${COBIEN_INSTALL_RUSTDESK:-1}"
RUSTDESK_VERSION="${COBIEN_RUSTDESK_VERSION:-1.4.6}"
RUSTDESK_URL="${COBIEN_RUSTDESK_URL:-https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-x86_64.deb}"
RUSTDESK_ARGS="${COBIEN_RUSTDESK_ARGS:---tray}"
AUTO_REBOOT_AFTER_SETUP="${COBIEN_AUTO_REBOOT_AFTER_SETUP:-1}"

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
STEP_TOTAL=10
ONLINE_ENV_FETCHED=0
BOOTSTRAP_APT_PACKAGES=(
    git
    curl
    openbox
    lightdm
    tint2
    xterm
    x11-xserver-utils
    wmctrl
    pipewire
    wireplumber
)

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
    if [[ "$INSTALL_RUSTDESK" == "1" ]]; then
        print_status_badge INFO "RustDesk ${RUSTDESK_VERSION} will be installed and added to autostart"
    else
        print_status_badge WARN "RustDesk installation is disabled by configuration"
    fi
    if [[ -n "$MASTER_ENV_FILE" ]]; then
        print_status_badge OK "Deployment env preselected: ${MASTER_ENV_FILE}"
    else
        print_status_badge INFO "You can fetch a fully generated furniture env from the CoBien admin before installation"
        print_status_badge WARN "No deployment env was passed yet; the installer will offer online and local discovery flows"
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
    print_kv "Display rotation" "$DISPLAY_ROTATION"
    print_kv "Kiosk sleep lock" "$DISABLE_SYSTEM_SLEEP"
    print_kv "Admin base URL" "$ADMIN_BASE_URL"
    print_kv "RustDesk version" "$RUSTDESK_VERSION"
    print_kv "RustDesk enabled" "$INSTALL_RUSTDESK"
    print_kv "Deployment env" "${MASTER_ENV_FILE:-auto-discovered later}"
    echo
}

safe_source_env_file() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    local key value line
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        key="${line%%=*}"
        value="${line#*=}"
        [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
        if [[ ${#value} -ge 2 && "$value" == '"'*'"' ]]; then
            value="${value:1:${#value}-2}"
            value="${value//\\\"/\"}"
            value="${value//\\\\/\\}"
        fi
        export "$key=$value"
    done < "$file"
    return 0
}

expand_path_value() {
    local value="${1-}"
    case "$value" in
        \$HOME) printf '%s\n' "$USER_HOME" ;;
        \$HOME/*) printf '%s/%s\n' "$USER_HOME" "${value#\$HOME/}" ;;
        \${HOME}) printf '%s\n' "$USER_HOME" ;;
        \${HOME}/*) printf '%s/%s\n' "$USER_HOME" "${value#\${HOME}/}" ;;
        "~") printf '%s\n' "$USER_HOME" ;;
        "~"/*) printf '%s/%s\n' "$USER_HOME" "${value#~/}" ;;
        *) printf '%s\n' "$value" ;;
    esac
}

load_selected_env_settings() {
    [[ -n "$MASTER_ENV_FILE" && -f "$MASTER_ENV_FILE" ]] || return 0
    safe_source_env_file "$MASTER_ENV_FILE"

    PROJECT_DIR="$(expand_path_value "${COBIEN_WORKSPACE_ROOT:-$PROJECT_DIR}")"
    FRONTEND_REPO_NAME="${COBIEN_FRONTEND_REPO_NAME:-$FRONTEND_REPO_NAME}"
    MQTT_REPO_NAME="${COBIEN_MQTT_REPO_NAME:-$MQTT_REPO_NAME}"
    BRANCH_NAME="${COBIEN_UPDATE_BRANCH:-$BRANCH_NAME}"
    DISPLAY_OUTPUT="${COBIEN_DISPLAY_OUTPUT:-$DISPLAY_OUTPUT}"
    DISPLAY_MODE="${COBIEN_DISPLAY_MODE:-$DISPLAY_MODE}"
    DISPLAY_ROTATION="${COBIEN_DISPLAY_ROTATION:-$DISPLAY_ROTATION}"
    DISABLE_SYSTEM_SLEEP="${COBIEN_DISABLE_SYSTEM_SLEEP:-$DISABLE_SYSTEM_SLEEP}"
    INSTALL_RUSTDESK="${COBIEN_INSTALL_RUSTDESK:-$INSTALL_RUSTDESK}"
    RUSTDESK_VERSION="${COBIEN_RUSTDESK_VERSION:-$RUSTDESK_VERSION}"
    RUSTDESK_URL="${COBIEN_RUSTDESK_URL:-https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-x86_64.deb}"
    RUSTDESK_ARGS="${COBIEN_RUSTDESK_ARGS:-$RUSTDESK_ARGS}"
    AUTO_REBOOT_AFTER_SETUP="${COBIEN_AUTO_REBOOT_AFTER_SETUP:-$AUTO_REBOOT_AFTER_SETUP}"

    FRONTEND_REPO="git@github.com:DeustoTech/${FRONTEND_REPO_NAME}.git"
    MQTT_REPO="git@github.com:DeustoTech/${MQTT_REPO_NAME}.git"
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

install_master_env_file() {
    local source_env="$1"
    local target_env="$SCRIPT_DIR/cobien.env"
    local source_abs target_abs

    [[ -n "$source_env" && -f "$source_env" ]] || return 1

    source_abs="$(realpath -m "$source_env" 2>/dev/null || printf '%s' "$source_env")"
    target_abs="$(realpath -m "$target_env" 2>/dev/null || printf '%s' "$target_env")"

    if [[ "$source_abs" != "$target_abs" ]]; then
        cp "$source_env" "$target_env"
        chmod 600 "$target_env"
        log OK "Installed deployment env as canonical file: $target_env"
    fi

    MASTER_ENV_FILE="$target_env"
    load_selected_env_settings
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
        "$PARENT_DIR"/env_for_furnitures/CoBien*.env \
        "$USER_HOME"/cobien.env \
        "$USER_HOME"/cobien/cobien.env
    do
        add_env_candidate "$pattern"
    done
}

choose_master_env_file() {
    fetch_online_master_env_file

    if [[ -n "$MASTER_ENV_FILE" && -f "$MASTER_ENV_FILE" ]]; then
        install_master_env_file "$MASTER_ENV_FILE"
        return 0
    fi

    discover_env_candidates

    if [[ -n "$MASTER_ENV_FILE" && -f "$MASTER_ENV_FILE" ]]; then
        install_master_env_file "$MASTER_ENV_FILE"
        return 0
    fi

    if [[ ${#ENV_CANDIDATES[@]} -eq 0 ]]; then
        log WARN "No deployment env candidates were found automatically."
        return 0
    fi

    if [[ "$NON_INTERACTIVE" == "1" ]]; then
        install_master_env_file "${ENV_CANDIDATES[0]}"
        log INFO "Using deployment env automatically: $MASTER_ENV_FILE"
        return 0
    fi

    local total="${#ENV_CANDIDATES[@]}"
    local download_option=$(( total + 1 ))

    echo
    printf '%b%s%b\n' "$COLOR_BOLD" "Detected deployment env candidates" "$COLOR_RESET"
    local i=1
    local candidate
    for candidate in "${ENV_CANDIDATES[@]}"; do
        printf '  %d. %s\n' "$i" "$candidate"
        i=$((i + 1))
    done
    printf '  %d. Download a new configuration from the CoBien admin portal\n' "$download_option"
    echo "  0. Continue without preselecting a deployment env"
    echo

    while true; do
        printf '%b[SELECT]%b Choose the deployment env to use [0-%d]: ' \
            "$COLOR_YELLOW" "$COLOR_RESET" "$download_option"
        read -r selection
        if [[ "$selection" == "0" || -z "$selection" ]]; then
            MASTER_ENV_FILE=""
            return 0
        fi
        if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection == download_option )); then
            _download_env_from_portal && return 0
            continue
        fi
        if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= total )); then
            install_master_env_file "${ENV_CANDIDATES[$((selection - 1))]}"
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

    if command -v python3 >/dev/null 2>&1; then
        print_status_badge OK "python3 is available"
    else
        print_status_badge ERROR "python3 is missing"
        missing=1
    fi

    if command -v curl >/dev/null 2>&1; then
        print_status_badge OK "curl is available"
    else
        print_status_badge ERROR "curl is missing"
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

prompt_text() {
    local prompt="$1"
    local default_value="${2:-}"
    local answer=""

    if [[ "$NON_INTERACTIVE" == "1" || "$AUTO_CONFIRM" == "1" ]]; then
        printf '%s' "$default_value"
        return 0
    fi

    if [[ -n "$default_value" ]]; then
        printf '%b[INPUT]%b %s [%s]: ' "$COLOR_YELLOW" "$COLOR_RESET" "$prompt" "$default_value" >&2
    else
        printf '%b[INPUT]%b %s: ' "$COLOR_YELLOW" "$COLOR_RESET" "$prompt" >&2
    fi
    read -r answer
    if [[ -z "$answer" ]]; then
        answer="$default_value"
    fi
    printf '%s' "$answer"
}

prompt_secret() {
    local prompt="$1"
    local answer=""

    if [[ "$NON_INTERACTIVE" == "1" || "$AUTO_CONFIRM" == "1" ]]; then
        printf '%s' "$ADMIN_PASSWORD"
        return 0
    fi

    printf '%b[SECRET]%b %s: ' "$COLOR_YELLOW" "$COLOR_RESET" "$prompt" >&2
    read -r -s answer
    printf '\n' >&2
    printf '%s' "$answer"
}

normalize_admin_base_url() {
    local raw_value="$1"
    local normalized="${raw_value%%\?*}"
    normalized="${normalized%%#*}"
    normalized="${normalized%/}"

    for suffix in \
        "/pizarra/api/admin/devices" \
        "/pizarra/api/admin/devices/" \
        "/pizarra/api/admin" \
        "/pizarra/api/admin/" \
        "/pizarra/api" \
        "/pizarra/api/" \
        "/pizarra" \
        "/pizarra/"
    do
        if [[ "$normalized" == *"$suffix" ]]; then
            normalized="${normalized%"$suffix"}"
            normalized="${normalized%/}"
            break
        fi
    done

    printf '%s' "$normalized"
}
render_online_device_choices() {
    local json_file="$1"
    python3 - "$json_file" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    payload = json.load(fh)
devices = payload.get("devices") or []
for idx, item in enumerate(devices, 1):
    device_id = str(item.get("device_id") or "").strip()
    display_name = str(item.get("display_name") or device_id).strip()
    status = str(item.get("status") or "unknown").strip()
    enabled = "enabled" if item.get("enabled", True) else "disabled"
    hidden = "hidden" if item.get("hidden_in_admin") else "visible"
    room = str(item.get("videocall_room") or device_id).strip()
    print(f"  {idx}. {display_name} [{device_id}] · room {room} · {status} · {enabled} · {hidden}")
PY
}

device_id_from_selection() {
    local json_file="$1"
    local selection="$2"
    python3 - "$json_file" "$selection" <<'PY'
import json, sys
path, raw_selection = sys.argv[1], sys.argv[2]
with open(path, "r", encoding="utf-8") as fh:
    payload = json.load(fh)
devices = payload.get("devices") or []
try:
    index = int(raw_selection)
except Exception:
    sys.exit(1)
if index < 1 or index > len(devices):
    sys.exit(1)
device_id = str(devices[index - 1].get("device_id") or "").strip()
if not device_id:
    sys.exit(1)
print(device_id)
PY
}

_curl_config_credentials() {
    local user="$1" pass="$2"
    # Escape backslashes then double-quotes per curl config-file syntax.
    user="${user//\\/\\\\}"; user="${user//\"/\\\"}"
    pass="${pass//\\/\\\\}"; pass="${pass//\"/\\\"}"
    printf 'user = "%s:%s"\n' "$user" "$pass"
}

_download_env_from_portal() {
    local devices_url device_env_url tmp_json selection="" selected_device=""
    local target_env="$SCRIPT_DIR/cobien.env"

    # Always re-prompt credentials so the user can switch device/account.
    ADMIN_BASE_URL="$(prompt_text "CoBien admin base URL" "$ADMIN_BASE_URL")"
    ADMIN_BASE_URL="$(normalize_admin_base_url "$ADMIN_BASE_URL")"
    ADMIN_USERNAME="$(prompt_text "Admin username" "$ADMIN_USERNAME")"
    ADMIN_PASSWORD="$(prompt_secret "Admin password")"

    if [[ -z "$ADMIN_BASE_URL" || -z "$ADMIN_USERNAME" || -z "$ADMIN_PASSWORD" ]]; then
        log WARN "Online configuration skipped: admin URL or credentials are incomplete."
        return 1
    fi

    log INFO "Using CoBien admin base URL: ${ADMIN_BASE_URL}"
    devices_url="${ADMIN_BASE_URL}/pizarra/api/admin/devices/"
    tmp_json="$(mktemp)"

    animate "Downloading the furniture list from the CoBien admin"
    if ! curl -fsS --config - -o "$tmp_json" "$devices_url" \
            <<< "$(_curl_config_credentials "$ADMIN_USERNAME" "$ADMIN_PASSWORD")" 2>/dev/null; then
        rm -f "$tmp_json"
        log WARN "Could not reach the CoBien admin or credentials are incorrect."
        return 1
    fi

    if [[ -n "$TARGET_DEVICE_ID" ]]; then
        selected_device="$TARGET_DEVICE_ID"
    elif [[ "$NON_INTERACTIVE" == "1" ]]; then
        rm -f "$tmp_json"
        log WARN "Online configuration in non-interactive mode requires COBIEN_TARGET_DEVICE_ID."
        return 1
    else
        echo
        printf '%b%s%b\n' "$COLOR_BOLD" "Available furniture devices in the CoBien admin" "$COLOR_RESET"
        render_online_device_choices "$tmp_json"
        echo "  0. Cancel"
        echo
        while true; do
            printf '%b[SELECT]%b Choose the furniture to configure [0-n]: ' "$COLOR_YELLOW" "$COLOR_RESET"
            read -r selection
            if [[ "$selection" == "0" || -z "$selection" ]]; then
                rm -f "$tmp_json"
                return 1
            fi
            if selected_device="$(device_id_from_selection "$tmp_json" "$selection" 2>/dev/null)"; then
                break
            fi
        done
    fi

    rm -f "$tmp_json"

    if [[ -z "$selected_device" ]]; then
        log WARN "No furniture device was selected."
        return 1
    fi

    device_env_url="${ADMIN_BASE_URL}/pizarra/api/admin/devices/${selected_device}/cobien-env/"
    animate "Downloading cobien.env for ${selected_device}"
    if ! curl -fsS --config - -o "$target_env" "$device_env_url" \
            <<< "$(_curl_config_credentials "$ADMIN_USERNAME" "$ADMIN_PASSWORD")" 2>/dev/null; then
        log WARN "Could not download the configuration for ${selected_device}."
        return 1
    fi
    chmod 600 "$target_env"

    MASTER_ENV_FILE="$target_env"
    FETCH_CONFIG_ONLINE="1"
    ONLINE_ENV_FETCHED=1
    load_selected_env_settings
    log OK "Downloaded deployment env for ${selected_device} → ${target_env}"
    return 0
}

fetch_online_master_env_file() {
    # Skip silently if already resolved or in non-interactive unattended mode.
    if [[ -n "$MASTER_ENV_FILE" && -f "$MASTER_ENV_FILE" ]]; then
        return 0
    fi

    if [[ "$FETCH_CONFIG_ONLINE" == "1" ]]; then
        _download_env_from_portal
        return
    fi

    if [[ "$NON_INTERACTIVE" == "1" && "$AUTO_CONFIRM" != "1" ]]; then
        return 0
    fi

    if confirm "Do you want to fetch the furniture configuration online from the CoBien admin?"; then
        _download_env_from_portal || true
    fi
}

run_cmd() {
    local description="$1"
    shift
    animate "$description"
    "$@"
}

installed_apt_package_version() {
    local package_name="$1"
    dpkg-query -W -f='${Version}' "$package_name" 2>/dev/null || true
}

install_missing_bootstrap_packages() {
    local missing_packages=()
    local package_name
    local version

    for package_name in "${BOOTSTRAP_APT_PACKAGES[@]}"; do
        version="$(installed_apt_package_version "$package_name")"
        if [[ -n "$version" ]]; then
            print_status_badge OK "Package already installed: ${package_name} (${version})"
        else
            missing_packages+=("$package_name")
        fi
    done

    if [[ "${#missing_packages[@]}" -eq 0 ]]; then
        log INFO "All required bootstrap packages are already installed."
        return 0
    fi

    log INFO "Missing bootstrap packages: ${missing_packages[*]}"
    run_cmd "Updating apt metadata" sudo apt update
    run_cmd "Installing missing packages" sudo apt install -y "${missing_packages[@]}"
}

_verify_repo_sync() {
    local repo_dir="$1"
    local repo_label="$2"
    local local_sha remote_sha
    local_sha="$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null || true)"
    remote_sha="$(git -C "$repo_dir" rev-parse "origin/$BRANCH_NAME" 2>/dev/null || true)"
    if [[ -z "$local_sha" || -z "$remote_sha" ]]; then
        log WARN "Could not verify sync state for ${repo_label}."
        return 0
    fi
    if [[ "$local_sha" != "$remote_sha" ]]; then
        log WARN "${repo_label} HEAD (${local_sha:0:7}) does not match origin/${BRANCH_NAME} (${remote_sha:0:7}) — pull did not complete cleanly."
        return 1
    fi
    print_status_badge OK "${repo_label} is up to date at ${local_sha:0:7}"
}

_report_repo_artifacts() {
    local repo_dir="$1"
    local repo_label="$2"
    local modified untracked

    # Tracked source files that have been locally modified (manual edits, runtime writes).
    modified="$(git -C "$repo_dir" diff --name-only HEAD 2>/dev/null || true)"
    # Untracked files not listed in .gitignore — true unexpected artifacts.
    untracked="$(git -C "$repo_dir" ls-files --others --exclude-standard 2>/dev/null || true)"

    if [[ -z "$modified" && -z "$untracked" ]]; then
        print_status_badge OK "No unexpected artifacts in ${repo_label}"
        return 0
    fi

    if [[ -n "$modified" ]]; then
        log WARN "${repo_label}: tracked files with local modifications:"
        while IFS= read -r f; do
            [[ -n "$f" ]] || continue
            log WARN "    M  $f"
        done <<< "$modified"
        log WARN "  These are version-controlled files changed outside of git."
        log WARN "  To discard: git -C \"$repo_dir\" restore ."
    fi

    if [[ -n "$untracked" ]]; then
        local count
        count="$(printf '%s\n' "$untracked" | grep -c .)"
        log WARN "${repo_label}: ${count} untracked file(s) not covered by .gitignore:"
        while IFS= read -r f; do
            [[ -n "$f" ]] || continue
            log WARN "    ?  $f"
        done <<< "$untracked"
        if [[ "$AUTO_CONFIRM" == "1" ]] || confirm "Remove these ${count} untracked file(s) from ${repo_label}?"; then
            git -C "$repo_dir" clean -fd
            print_status_badge OK "Untracked artifacts removed from ${repo_label}"
        else
            log WARN "Untracked artifacts left in place in ${repo_label}."
        fi
    fi
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
            run_cmd "Pulling latest ${repo_label}" git pull --ff-only origin "$BRANCH_NAME"
        )
        _verify_repo_sync "$repo_dir" "$repo_label"
        _report_repo_artifacts "$repo_dir" "$repo_label"
    fi
}

write_openbox_autostart() {
    mkdir -p "$USER_HOME/.config/openbox"

    cat > "$USER_HOME/.config/openbox/autostart" <<EOF
#!/usr/bin/env bash

sleep 2
xrandr --output ${DISPLAY_OUTPUT} --mode ${DISPLAY_MODE} --rotate ${DISPLAY_ROTATION} >/dev/null 2>&1 || true

if [ "${DISABLE_SYSTEM_SLEEP}" = "1" ] && command -v xset >/dev/null 2>&1; then
  xset s off >/tmp/cobien-xset.log 2>&1 || true
  xset -dpms >/tmp/cobien-xset.log 2>&1 || true
  xset s noblank >/tmp/cobien-xset.log 2>&1 || true
fi

pgrep -u "${USER_NAME}" pipewire >/dev/null || pipewire >/tmp/cobien-pipewire.log 2>&1 &
pgrep -u "${USER_NAME}" wireplumber >/dev/null || wireplumber >/tmp/cobien-wireplumber.log 2>&1 &

if [ -x "${SCRIPT_DIR}/import-systemd-user-env.sh" ]; then
  "${SCRIPT_DIR}/import-systemd-user-env.sh" >/tmp/cobien-import-session-env.log 2>&1 || true
fi

if [ "${INSTALL_RUSTDESK}" = "1" ] && [ -x "/usr/bin/rustdesk" ]; then
  pgrep -u "${USER_NAME}" -x rustdesk >/dev/null || /usr/bin/rustdesk ${RUSTDESK_ARGS} >/tmp/cobien-rustdesk.log 2>&1 &
fi
EOF

    chmod +x "$USER_HOME/.config/openbox/autostart"
}

configure_kiosk_power_management() {
    if [[ "$DISABLE_SYSTEM_SLEEP" != "1" ]]; then
        log INFO "Kiosk power-management lock is disabled by configuration."
        return 0
    fi

    sudo mkdir -p /etc/systemd/logind.conf.d
    sudo tee /etc/systemd/logind.conf.d/50-cobien-kiosk.conf > /dev/null <<EOF
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
EOF

    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target >/dev/null 2>&1 || true
    sudo systemctl restart systemd-logind >/dev/null 2>&1 || true

    print_status_badge OK "Suspend, hibernate and idle sleep disabled for kiosk mode"
    print_status_badge OK "Openbox sessions will disable DPMS and screen blanking"
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

install_rustdesk() {
    if [[ "$INSTALL_RUSTDESK" != "1" ]]; then
        log INFO "RustDesk installation skipped by configuration."
        return 0
    fi

    local installed_version=""
    installed_version="$(installed_apt_package_version "rustdesk")"
    if [[ -n "$installed_version" && "$installed_version" == "$RUSTDESK_VERSION"* && -x /usr/bin/rustdesk ]]; then
        print_status_badge OK "RustDesk ${installed_version} already installed"
        return 0
    fi

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local deb_path="$tmp_dir/rustdesk-${RUSTDESK_VERSION}-x86_64.deb"
    run_cmd "Downloading RustDesk ${RUSTDESK_VERSION}" curl -fL "$RUSTDESK_URL" -o "$deb_path"

    if ! dpkg-deb --info "$deb_path" >/dev/null 2>&1; then
        log ERROR "Downloaded RustDesk package is not a valid .deb file — aborting install"
        rm -rf "$tmp_dir"
        return 1
    fi
    local deb_pkg
    deb_pkg="$(dpkg-deb --field "$deb_path" Package 2>/dev/null || true)"
    if [[ "$deb_pkg" != "rustdesk" ]]; then
        log ERROR "Downloaded .deb Package field is '${deb_pkg}', expected 'rustdesk' — aborting install"
        rm -rf "$tmp_dir"
        return 1
    fi

    run_cmd "Installing RustDesk ${RUSTDESK_VERSION}" sudo apt install -y "$deb_path"
    rm -rf "$tmp_dir"

    if [[ ! -x /usr/bin/rustdesk ]]; then
        log ERROR "RustDesk was not found at /usr/bin/rustdesk after installation."
        return 1
    fi

    print_status_badge OK "RustDesk ${RUSTDESK_VERSION} installed"
}

install_systemd_user_units() {
    local systemd_src_dir="$SCRIPT_DIR/systemd"
    local systemd_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
    local systemd_override_dir="$systemd_user_dir/cobien-launcher.service.d"
    local autostart_dir="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
    local autostart_file="$autostart_dir/cobien-import-session-env.desktop"
    local timers_wants_dir="$systemd_user_dir/timers.target.wants"
    local graphical_wants_dir="$systemd_user_dir/graphical-session.target.wants"

    mkdir -p "$systemd_user_dir" "$autostart_dir" "$timers_wants_dir" "$graphical_wants_dir"

    if command -v loginctl >/dev/null 2>&1; then
        loginctl enable-linger "$USER" || true
        print_status_badge OK "Enabled linger for user: $USER"
    fi

    install -m 0644 "$systemd_src_dir/cobien-launcher.service" "$systemd_user_dir/cobien-launcher.service"
    install -m 0644 "$systemd_src_dir/cobien-update.service" "$systemd_user_dir/cobien-update.service"
    install -m 0644 "$systemd_src_dir/cobien-update.timer" "$systemd_user_dir/cobien-update.timer"
    rm -rf "$systemd_override_dir"

    cat > "$autostart_file" <<EOF
[Desktop Entry]
Type=Application
Name=CoBien Session Env Import
Comment=Import graphical session variables into systemd user services
Exec=/bin/bash $SCRIPT_DIR/import-systemd-user-env.sh
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=2
X-XFCE-Autostart-enabled=true
X-MATE-Autostart-enabled=true
NoDisplay=true
Terminal=false
EOF

    ln -sfn ../cobien-launcher.service "$graphical_wants_dir/cobien-launcher.service"
    ln -sfn ../cobien-update.timer "$timers_wants_dir/cobien-update.timer"

    systemctl --user daemon-reload >/dev/null 2>&1 || true
    systemctl --user enable cobien-launcher.service cobien-update.timer >/dev/null 2>&1 || true

    print_status_badge OK "Systemd user units installed"
    print_status_badge OK "Graphical session import hook installed"
}

run_launcher_setup_mode() {
    local launcher_cmd=(
        "$SCRIPT_DIR/cobien-launcher.sh"
        --mode setup
        --non-interactive
        --yes
        --workspace "$PROJECT_DIR"
        --frontend-name "$FRONTEND_REPO_NAME"
        --mqtt-name "$MQTT_REPO_NAME"
        --branch "$BRANCH_NAME"
    )

    animate "Preparing the CoBien runtime with cobien-launcher.sh"
    if [[ -n "$MASTER_ENV_FILE" ]]; then
        COBIEN_MASTER_ENV_FILE="$MASTER_ENV_FILE" "${launcher_cmd[@]}"
    else
        "${launcher_cmd[@]}"
    fi
}

finalize_with_reboot() {
    echo
    print_rule
    printf '%b%s%b\n' "$COLOR_BOLD$COLOR_BLUE" "The furniture is fully prepared." "$COLOR_RESET"
    print_status_badge OK "The application runtime has been prepared but not launched yet"
    print_status_badge OK "Systemd user services are installed and enabled for the next login"
    if [[ "$INSTALL_RUSTDESK" == "1" ]]; then
        print_status_badge OK "RustDesk will be started automatically by Openbox after reboot"
    fi
    echo
    echo "The device now needs a reboot so that Openbox autologin, RustDesk and the CoBien runtime"
    echo "come up naturally in the new session."
    echo

    if [[ "$AUTO_REBOOT_AFTER_SETUP" == "1" ]]; then
        print_status_badge INFO "The system will reboot in 10 seconds. Press Ctrl+C now if you want to stop it."
        sleep 10
        sudo reboot
    else
        print_status_badge INFO "Automatic reboot disabled. Run 'sudo reboot' when you are ready."
    fi
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
    if [[ "$INSTALL_RUSTDESK" == "1" ]]; then
        print_status_badge OK "RustDesk installed"
    fi
    echo
    print_kv "Target user" "$USER_NAME"
    print_kv "Target home" "$USER_HOME"
    print_kv "Workspace" "$PROJECT_DIR"
    print_kv "Branch" "$BRANCH_NAME"
    print_kv "Frontend repo" "$PROJECT_DIR/$FRONTEND_REPO_NAME"
    print_kv "MQTT repo" "$PROJECT_DIR/$MQTT_REPO_NAME"
    print_kv "Desktop session" "Openbox via LightDM autologin"
    print_kv "Sleep prevention" "$DISABLE_SYSTEM_SLEEP"
    print_kv "RustDesk version" "$RUSTDESK_VERSION"
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
    load_selected_env_settings
    print_preflight_snapshot

    if [[ "$ONLINE_ENV_FETCHED" == "1" ]]; then
        log INFO "Online deployment env downloaded successfully. Continuing with unattended setup."
    else
        if ! confirm "Continue with the full furniture environment setup?"; then
            log WARN "Setup cancelled by the user."
            exit 0
        fi
    fi

    phase "Checking prerequisites" "Verifying the installer tools and the selected deployment env before changing the system."
    if ! preflight_checks; then
        log ERROR "Preflight checks failed. Fix the missing items and run the setup again."
        exit 1
    fi

    phase "Installing system packages" "Openbox, LightDM, audio stack and display helpers will be verified and installed only when missing."
    install_missing_bootstrap_packages

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
    run_cmd "Applying kiosk power policy" configure_kiosk_power_management

    phase "Validating the graphical session" "Checking that the Openbox session entry is installed and ready."
    if [ ! -f /usr/share/xsessions/openbox.desktop ]; then
        log ERROR "Openbox session file not found: /usr/share/xsessions/openbox.desktop"
        exit 1
    fi
    log OK "Openbox session file detected."

    phase "Installing RustDesk" "The remote support tool will be installed and wired into the graphical session."
    install_rustdesk

    phase "Preparing the application runtime" "Running cobien-launcher in setup mode so the runtime is fully ready before reboot."
    run_launcher_setup_mode

    phase "Installing user services" "Registering CoBien systemd user units without starting the runtime in this session."
    install_systemd_user_units

    print_summary
    phase "Finalizing installation" "Reviewing the result and handing off to the reboot that will activate the full furniture session."
    finalize_with_reboot
}

main "$@"
