#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCHER_ROOT_DEFAULT="$SCRIPT_DIR"

WORKSPACE_ROOT_DEFAULT="${HOME}/cobien"
FRONTEND_REPO_NAME_DEFAULT="cobien_FrontEnd"
MQTT_REPO_NAME_DEFAULT="cobien_MQTT_Dictionnary"
BRANCH_NAME_DEFAULT="master"
CRON_SCHEDULE_DEFAULT="0 1 * * *"
POLL_INTERVAL_DEFAULT="60"
CAN_LOG_ENABLE_DEFAULT="1"
LOG_RETENTION_DAYS_DEFAULT="90"

MODE="run"
WORKSPACE_ROOT="${COBIEN_WORKSPACE_ROOT:-$WORKSPACE_ROOT_DEFAULT}"
FRONTEND_REPO_NAME="${COBIEN_FRONTEND_REPO_NAME:-$FRONTEND_REPO_NAME_DEFAULT}"
MQTT_REPO_NAME="${COBIEN_MQTT_REPO_NAME:-$MQTT_REPO_NAME_DEFAULT}"
BRANCH_NAME="${COBIEN_UPDATE_BRANCH:-$BRANCH_NAME_DEFAULT}"
RUN_UPDATE_ONCE="${COBIEN_RUN_UPDATE_ONCE:-0}"
INSTALL_SYSTEM_DEPS="${COBIEN_INSTALL_SYSTEM_DEPS:-1}"
RECREATE_VENV="${COBIEN_RECREATE_VENV:-0}"
ENABLE_WATCH="${COBIEN_ENABLE_WATCH:-1}"
INSTALL_CRON="${COBIEN_INSTALL_CRON:-0}"
INSTALL_SYSTEMD_USER="${COBIEN_INSTALL_SYSTEMD_USER:-0}"
CRON_SCHEDULE="${COBIEN_CRON_SCHEDULE:-$CRON_SCHEDULE_DEFAULT}"
NON_INTERACTIVE="${COBIEN_NON_INTERACTIVE:-0}"
AUTO_CONFIRM="${COBIEN_AUTO_CONFIRM:-0}"
REMOTE_NAME="${COBIEN_UPDATE_REMOTE:-origin}"
POLL_INTERVAL_SEC="${COBIEN_UPDATE_INTERVAL_SEC:-$POLL_INTERVAL_DEFAULT}"
CAN_LOG_ENABLE="${COBIEN_CAN_LOG_ENABLE:-$CAN_LOG_ENABLE_DEFAULT}"
LOG_RETENTION_DAYS="${COBIEN_LOG_RETENTION_DAYS:-$LOG_RETENTION_DAYS_DEFAULT}"
RELAUNCH_AFTER_UPDATE="${COBIEN_RELAUNCH_AFTER_UPDATE:-0}"
FORCE_RESTART="${COBIEN_FORCE_RESTART:-0}"
APP_LANGUAGE="${COBIEN_APP_LANGUAGE:-es}"
DEVICE_ID="${COBIEN_DEVICE_ID:-}"
VIDEOCALL_ROOM="${COBIEN_VIDEOCALL_ROOM:-}"
NOTIFY_API_KEY="${COBIEN_NOTIFY_API_KEY:-}"
VIDEOCALL_DEVICE_API_KEY="${COBIEN_VIDEOCALL_DEVICE_API_KEY:-}"
DEVICE_LOCATION="${COBIEN_DEVICE_LOCATION:-}"
HARDWARE_MODE="${COBIEN_HARDWARE_MODE:-auto}"
SETTINGS_PIN="${COBIEN_SETTINGS_PIN:-}"
RESTART_PIN="${COBIEN_RESTART_PIN:-}"
WEATHER_CITIES_JSON="${COBIEN_WEATHER_CITIES_JSON:-[\"Bilbao\",\"Toulouse\",\"Logroño\"]}"
WEATHER_CITY_CATALOG_JSON="${COBIEN_WEATHER_CITY_CATALOG_JSON:-}"
WEATHER_PRIMARY_CITY="${COBIEN_WEATHER_PRIMARY_CITY:-Bilbao}"
BUTTON_COLORS_JSON="${COBIEN_BUTTON_COLORS_JSON:-{}}"
RFID_ACTIONS_JSON="${COBIEN_RFID_ACTIONS_JSON:-{}}"
MICROPHONE_DEVICE="${COBIEN_MICROPHONE_DEVICE:-}"
AUDIO_OUTPUT_DEVICE="${COBIEN_AUDIO_OUTPUT_DEVICE:-}"
JOKE_CATEGORY="${COBIEN_JOKE_CATEGORY:-general}"
IDLE_TIMEOUT_SEC="${COBIEN_IDLE_TIMEOUT_SEC:-60}"
NOTIFICATIONS_JSON="${COBIEN_NOTIFICATIONS_JSON:-}"
BACKEND_BASE_URL="${COBIEN_BACKEND_BASE_URL:-https://portal.co-bien.eu}"
DEVICE_POLL_URL="${COBIEN_DEVICE_POLL_URL:-}"
DEVICE_POLL_INTERVAL_SEC="${COBIEN_DEVICE_POLL_INTERVAL_SEC:-5}"
DEVICE_HEARTBEAT_URL="${COBIEN_DEVICE_HEARTBEAT_URL:-}"
DEVICE_HEARTBEAT_INTERVAL_SEC="${COBIEN_DEVICE_HEARTBEAT_INTERVAL_SEC:-60}"
OWM_API_KEY="${OWM_API_KEY:-}"
NEWS_API_KEY="${NEWS_API_KEY:-}"
MONGO_URI="${MONGO_URI:-}"
PIZARRA_NOTIFY_URL="${COBIEN_PIZARRA_NOTIFY_URL:-}"
PIZARRA_API_URL="${COBIEN_PIZARRA_API_URL:-}"
PIZARRA_DELETE_URL_TEMPLATE="${COBIEN_PIZARRA_DELETE_URL_TEMPLATE:-}"
CONTACTS_API_URL="${COBIEN_CONTACTS_API_URL:-}"
ICSO_TELEMETRY_URL="${COBIEN_ICSO_TELEMETRY_URL:-}"
ICSO_EVENTS_URL="${COBIEN_ICSO_EVENTS_URL:-}"
DEVICE_VIDEOCALL_SESSION_URL="${COBIEN_DEVICE_VIDEOCALL_SESSION_URL:-}"
PORTAL_VIDEOCALL_URL="${COBIEN_PORTAL_VIDEOCALL_URL:-}"
PORTAL_VIDEOCALL_DEVICE_URL="${COBIEN_PORTAL_VIDEOCALL_DEVICE_URL:-}"
PORTAL_CALL_ANSWERED_URL="${COBIEN_PORTAL_CALL_ANSWERED_URL:-}"
MQTT_LOCAL_BROKER="${COBIEN_MQTT_LOCAL_BROKER:-localhost}"
MQTT_LOCAL_PORT="${COBIEN_MQTT_LOCAL_PORT:-1883}"
HTTP_TIMEOUT_SEC="${COBIEN_HTTP_TIMEOUT:-8}"
TTS_ENGINE="${COBIEN_TTS_ENGINE:-piper}"
TTS_RATE="${COBIEN_TTS_RATE:-155}"
TTS_VOLUME="${COBIEN_TTS_VOLUME:-0.85}"
TTS_PIPER_BIN="${COBIEN_TTS_PIPER_BIN:-}"
TTS_PIPER_PROVIDER="${COBIEN_TTS_PIPER_PROVIDER:-}"
TTS_PIPER_VERSION="${COBIEN_TTS_PIPER_VERSION:-}"
TTS_PIPER_MODEL_ES="${COBIEN_TTS_PIPER_MODEL_ES:-}"
TTS_PIPER_MODEL_FR="${COBIEN_TTS_PIPER_MODEL_FR:-}"
TTS_PIPER_MODEL_ES_MALE="${COBIEN_TTS_PIPER_MODEL_ES_MALE:-}"
TTS_PIPER_MODEL_ES_FEMALE="${COBIEN_TTS_PIPER_MODEL_ES_FEMALE:-}"
TTS_PIPER_MODEL_FR_MALE="${COBIEN_TTS_PIPER_MODEL_FR_MALE:-}"
TTS_PIPER_MODEL_FR_FEMALE="${COBIEN_TTS_PIPER_MODEL_FR_FEMALE:-}"
TTS_PIPER_MODEL_ES_URL="${COBIEN_TTS_PIPER_MODEL_ES_URL:-}"
TTS_PIPER_MODEL_FR_URL="${COBIEN_TTS_PIPER_MODEL_FR_URL:-}"
TTS_PIPER_VOICE_ES="${COBIEN_TTS_PIPER_VOICE_ES:-male}"
TTS_PIPER_VOICE_FR="${COBIEN_TTS_PIPER_VOICE_FR:-male}"
TTS_PIPER_DEFAULT_MODEL_ES_MALE="es_ES-davefx-medium"
TTS_PIPER_DEFAULT_MODEL_ES_FEMALE="es_ES-mls_10246-low"
TTS_PIPER_DEFAULT_MODEL_FR_MALE="fr_FR-mls_1840-low"
TTS_PIPER_DEFAULT_MODEL_FR_FEMALE="fr_FR-siwis-medium"
TTS_PIPER_DEFAULT_MODEL_ES_MALE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/davefx/medium/es_ES-davefx-medium.onnx"
TTS_PIPER_DEFAULT_MODEL_ES_FEMALE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/mls_10246/low/es_ES-mls_10246-low.onnx"
TTS_PIPER_DEFAULT_MODEL_FR_MALE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/fr/fr_FR/mls_1840/low/fr_FR-mls_1840-low.onnx"
TTS_PIPER_DEFAULT_MODEL_FR_FEMALE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/main/fr/fr_FR/siwis/medium/fr_FR-siwis-medium.onnx"

TTS_PIPER_MODEL_ES_MALE_URL="${COBIEN_TTS_PIPER_MODEL_ES_MALE_URL:-$TTS_PIPER_DEFAULT_MODEL_ES_MALE_URL}"
TTS_PIPER_MODEL_ES_FEMALE_URL="${COBIEN_TTS_PIPER_MODEL_ES_FEMALE_URL:-$TTS_PIPER_DEFAULT_MODEL_ES_FEMALE_URL}"
TTS_PIPER_MODEL_FR_MALE_URL="${COBIEN_TTS_PIPER_MODEL_FR_MALE_URL:-$TTS_PIPER_DEFAULT_MODEL_FR_MALE_URL}"
TTS_PIPER_MODEL_FR_FEMALE_URL="${COBIEN_TTS_PIPER_MODEL_FR_FEMALE_URL:-$TTS_PIPER_DEFAULT_MODEL_FR_FEMALE_URL}"
DISABLE_SYSTEM_SLEEP="${COBIEN_DISABLE_SYSTEM_SLEEP:-0}"
OPENWEATHER_CURRENT_URL="${COBIEN_OPENWEATHER_CURRENT_URL:-https://api.openweathermap.org/data/2.5/weather}"
OPENWEATHER_FORECAST_URL="${COBIEN_OPENWEATHER_FORECAST_URL:-https://api.openweathermap.org/data/2.5/forecast}"
NEWS_API_URL="${COBIEN_NEWS_API_URL:-https://newsapi.org/v2/top-headlines}"
OPEN_METEO_URL="${COBIEN_OPEN_METEO_URL:-https://api.open-meteo.com/v1/forecast}"
NOMINATIM_SEARCH_URL="${COBIEN_NOMINATIM_SEARCH_URL:-https://nominatim.openstreetmap.org/search}"
TTS_PIPER_RELEASE_TAG_DEFAULT="2023.11.14-2"
[[ -z "$TTS_PIPER_MODEL_ES_MALE_URL" ]] && TTS_PIPER_MODEL_ES_MALE_URL="$TTS_PIPER_DEFAULT_MODEL_ES_MALE_URL"
[[ -z "$TTS_PIPER_MODEL_ES_FEMALE_URL" ]] && TTS_PIPER_MODEL_ES_FEMALE_URL="$TTS_PIPER_DEFAULT_MODEL_ES_FEMALE_URL"
[[ -z "$TTS_PIPER_MODEL_FR_MALE_URL" ]] && TTS_PIPER_MODEL_FR_MALE_URL="$TTS_PIPER_DEFAULT_MODEL_FR_MALE_URL"
[[ -z "$TTS_PIPER_MODEL_FR_FEMALE_URL" ]] && TTS_PIPER_MODEL_FR_FEMALE_URL="$TTS_PIPER_DEFAULT_MODEL_FR_FEMALE_URL"
PYTHON_BIN="${COBIEN_BOOTSTRAP_PYTHON_BIN:-}"
UV_BIN="${COBIEN_BOOTSTRAP_UV_BIN:-}"
PYTHON_REQUEST="${COBIEN_BOOTSTRAP_PYTHON_VERSION:-${COBIEN_UV_PYTHON:-3.13}}"
ARGS_PROVIDED="0"
GLOBAL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cobien"
GLOBAL_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cobien"
GLOBAL_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cobien"
GLOBAL_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/cobien"
LAST_RUN_CONFIG_FILE="$GLOBAL_CONFIG_DIR/launcher-last.env"
MASTER_ENV_FILE=""
LOCK_FILE="${COBIEN_LAUNCHER_LOCK_FILE:-/tmp/cobien-launcher.lock}"
LOCK_DIR="${LOCK_FILE}.d"
LOCK_PID_FILE="$LOCK_DIR/pid"
CURRENT_PHASE="bootstrap"
LAUNCHER_ROOT="${COBIEN_LAUNCHER_ROOT:-$LAUNCHER_ROOT_DEFAULT}"

usage() {
  cat <<EOF
Usage:
  $(basename "$0")
  $(basename "$0") --workspace "$HOME/cobien"
  $(basename "$0") --mode setup --workspace "$HOME/cobien"
  $(basename "$0") --mode update-once
  $(basename "$0") --mode watch
  $(basename "$0") --mode launch
  $(basename "$0") --mode clean-launch
  $(basename "$0") --mode dry-run
  $(basename "$0") --mode diagnose

Modes:
  run           Full interactive or unattended flow
  setup         Prepare dependencies, uv, Python and .venv only
  update-once   Check for changes and relaunch if updated
  watch         Check for changes every minute
  launch        Launch the furniture runtime
  clean-launch  Stop previous launcher/runtime state and relaunch cleanly
  dry-run       Print resolved configuration
  diagnose      Run extended diagnostics to help debug runtime and install issues

Options:
  --workspace PATH
  --frontend-name NAME
  --mqtt-name NAME
  --branch NAME
  --run-update-once
  --enable-watch
  --install-cron
  --install-systemd-user
  --cron-schedule "0 1 * * *"
  --device-id NAME
  --videocall-room NAME
  --device-location LOCATION
  --app-language es|fr
  --hardware-mode real|mock|auto
  --videocall-device-api-key KEY
  --tts-engine ENGINE
  --tts-piper-bin PATH
  --tts-piper-model-es PATH
  --tts-piper-model-fr PATH
  --tts-piper-model-es-url URL
  --tts-piper-model-fr-url URL
  --diagnose      Run extended diagnostics (local checks, services, files)
  --tts-piper-voice-es male|female
  --tts-piper-voice-fr male|female
  --recreate-venv
  --force-restart
  --clean-launch
  --skip-system-deps
  --non-interactive
  --yes
  -h, --help
EOF
}

COLOR_RESET=""
COLOR_BOLD=""
COLOR_DIM=""
COLOR_BLUE=""
COLOR_CYAN=""
COLOR_GREEN=""
COLOR_YELLOW=""
COLOR_RED=""
COLOR_MAGENTA=""
COLOR_PANEL=""

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
    COLOR_PANEL=$'\033[48;5;255m'
  fi
}

log() {
  local msg="$*"
  local color="$COLOR_CYAN"
  case "$msg" in
    WARN:*|Warning:*|warning:*) color="$COLOR_YELLOW" ;;
    ERROR:*|Error:*|error:*|Failed*|Unable*) color="$COLOR_RED" ;;
    OK:*|SUCCESS:*|Success*) color="$COLOR_GREEN" ;;
  esac
  printf '%b[COBIEN]%b %s\n' "$color" "$COLOR_RESET" "$msg"
}

log_section() {
  printf '\n%b%s%b\n' "$COLOR_BOLD$COLOR_BLUE" "$*" "$COLOR_RESET"
}

log_phase_banner() {
  local title="$1"
  local detail="${2:-}"
  printf '\n%b%s%b\n' "$COLOR_BOLD$COLOR_MAGENTA" "=== $title ===" "$COLOR_RESET"
  if [[ -n "$detail" ]]; then
    printf '%b%s%b\n' "$COLOR_DIM" "$detail" "$COLOR_RESET"
  fi
}

animate_status() {
  local message="$1"
  local dots="${2:-3}"
  local i
  printf '%b[COBIEN]%b %s' "$COLOR_CYAN" "$COLOR_RESET" "$message"
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

set_phase() {
  CURRENT_PHASE="$1"
}

print_file_status() {
  local label="$1"
  local path="$2"
  local kind="${3:-file}"
  local status="missing"
  if [[ "$kind" == "dir" ]]; then
    [[ -d "$path" ]] && status="ok"
  else
    [[ -f "$path" ]] && status="ok"
  fi
  printf '  %-24s %-8s %s\n' "$label" "$status" "$path"
}

emit_failure_context() {
  local line_no="${1:-?}"
  local exit_code="${2:-1}"
  echo
  log_section "Launcher failure context"
  log "ERROR: launcher failed at phase='$CURRENT_PHASE' line=$line_no exit_code=$exit_code"
  log "MODE=$MODE"
  log "WORKSPACE_ROOT=$WORKSPACE_ROOT"
  log "FRONTEND_REPO=${FRONTEND_REPO:-unresolved}"
  log "MQTT_REPO=${MQTT_REPO:-unresolved}"
  log "ENV_FILE=${ENV_FILE:-unresolved}"
  log "MASTER_ENV_FILE=${MASTER_ENV_FILE:-unresolved}"
  log "PYTHON_REQUEST=${PYTHON_REQUEST:-unset}"
  log "UV_BIN=${UV_BIN:-unset}"
}

on_launcher_error() {
  local exit_code="$1"
  local line_no="$2"
  emit_failure_context "$line_no" "$exit_code"
  exit "$exit_code"
}

trap 'on_launcher_error $? $LINENO' ERR

print_banner() {
  cat <<EOF
${COLOR_BOLD}${COLOR_BLUE}
  ____      ____  _           
 / ___|___ | __ )(_) ___ _ __ 
| |   / _ \|  _ \| |/ _ \ '_ \\
| |__| (_) | |_) | |  __/ | | |
 \____\___/|____/|_|\___|_| |_|
${COLOR_RESET}
CoBien Furniture Launcher
EOF
}

print_intro() {
  print_banner
  echo
  echo "This assistant prepares the furniture runtime, backend connectivity, videoconference access,"
  echo "voice models, local config and the supervised launch flow."
  echo
}

print_key_value() {
  local label="$1"
  local value="$2"
  printf '  %-20s %s\n' "$label" "$value"
}

print_question_group() {
  local title="$1"
  echo
  printf '%b%s%b\n' "$COLOR_BOLD$COLOR_CYAN" "$title" "$COLOR_RESET"
}

tty_read() {
  local silent="${1:-0}"
  local prompt="${2:-}"
  local __resultvar="${3:-REPLY}"
  local value=""
  local input_fd

  if [[ -r /dev/tty ]]; then
    exec {input_fd}</dev/tty
  else
    input_fd=0
  fi

  if [[ "$silent" == "1" ]]; then
    if ! read -r -s -u "$input_fd" -p "$prompt" value; then
      [[ "$input_fd" != "0" ]] && exec {input_fd}<&-
      return 1
    fi
    echo
  else
    if ! read -r -u "$input_fd" -p "$prompt" value; then
      [[ "$input_fd" != "0" ]] && exec {input_fd}<&-
      return 1
    fi
  fi

  [[ "$input_fd" != "0" ]] && exec {input_fd}<&-
  printf -v "$__resultvar" '%s' "$value"
  return 0
}

print_runtime_summary() {
  echo
  echo "Deployment summary"
  echo "------------------"
  print_key_value "Phase" "$CURRENT_PHASE"
  print_key_value "Mode" "$MODE"
  print_key_value "Workspace" "$WORKSPACE_ROOT"
  if [[ "${force_full_install_from_master_env:-0}" == "1" ]]; then
    print_key_value "Deployment env" "$MASTER_ENV_FILE"
    print_key_value "Master env mode" "full install"
  fi
  print_key_value "Reuse install" "$reuse_existing_installation"
  print_key_value "Install deps" "$INSTALL_SYSTEM_DEPS"
  print_key_value "Recreate .venv" "$RECREATE_VENV"
  print_key_value "Update check" "$RUN_UPDATE_ONCE"
  print_key_value "Watch mode" "$ENABLE_WATCH"
  print_key_value "Language" "$APP_LANGUAGE"
  print_key_value "Device ID" "$DEVICE_ID"
  print_key_value "Videocall room" "$VIDEOCALL_ROOM"
  print_key_value "Notify key" "$([[ -n "$NOTIFY_API_KEY" ]] && echo configured || echo missing)"
  print_key_value "Videocall key" "$([[ -n "$VIDEOCALL_DEVICE_API_KEY" ]] && echo configured || echo missing)"
  print_key_value "Backend" "$BACKEND_BASE_URL"
  print_key_value "Poll URL" "$DEVICE_POLL_URL"
  print_key_value "Contacts URL" "$CONTACTS_API_URL"
  print_key_value "Location" "$DEVICE_LOCATION"
  print_key_value "Hardware mode" "$HARDWARE_MODE"
  print_key_value "TTS engine" "$TTS_ENGINE"
  print_key_value "Python" "${PYTHON_REQUEST:-unset}"
  print_key_value "UV" "${UV_BIN:-auto}"
  print_key_value "Install cron" "$INSTALL_CRON"
  if [[ "$INSTALL_CRON" == "1" ]]; then
    print_key_value "Cron schedule" "$CRON_SCHEDULE"
  fi
  print_key_value "Install systemd" "$INSTALL_SYSTEMD_USER"
  echo

  echo "Resolved files"
  echo "--------------"
  print_file_status "Deployment env" "${MASTER_ENV_FILE:-unresolved}"
  print_file_status "Runtime env" "${ENV_FILE:-unresolved}"
  print_file_status "Config dir" "${GLOBAL_CONFIG_DIR:-unresolved}" dir
  print_file_status "State dir" "${GLOBAL_STATE_DIR:-unresolved}" dir
  print_file_status "Cache dir" "${GLOBAL_CACHE_DIR:-unresolved}" dir
  print_file_status "Data dir" "${GLOBAL_DATA_DIR:-unresolved}" dir
  print_file_status "Unified config" "${FRONTEND_APP_DIR:-}/config/config.local.json"
  print_file_status "Version" "${FRONTEND_APP_DIR:-}/VERSION"
  print_file_status "Pyproject" "${FRONTEND_APP_DIR:-}/pyproject.toml"
  print_file_status "Launcher contract" "${FRONTEND_APP_DIR:-}/config_runtime.py"
  print_file_status "Main app" "${FRONTEND_APP_DIR:-}/mainApp.py"
  print_file_status "Bridge dir" "${BRIDGE_DIR:-unresolved}" dir
  print_file_status "CAN config" "${CAN_CONFIG:-unresolved}"
  echo
}

run_full_install_plan() {
  local reuse_existing_installation="${1:-0}"
  set_phase "full-install-plan"

  set_service_defaults
  validate_current_runtime_config
  resolve_paths
  validate_runtime_file_dependencies

  if [[ "$force_full_install_from_master_env" == "1" ]]; then
    reuse_existing_installation="0"
    INSTALL_SYSTEM_DEPS="${INSTALL_SYSTEM_DEPS:-1}"
    RECREATE_VENV="1"
  fi

  if ! has_systemd_user_launcher_service; then
    INSTALL_SYSTEMD_USER="1"
    log "First run detected: systemd user service missing, auto-install enabled."
  fi

  reconcile_update_supervision_mode

  echo
  echo "Detected paths:"
  echo "  Frontend: $FRONTEND_REPO"
  echo "  MQTT:     $MQTT_REPO"
  echo

  [[ -d "$FRONTEND_REPO/.git" ]] || { echo "Frontend repository not found at: $FRONTEND_REPO"; exit 1; }
  [[ -d "$MQTT_REPO/.git" ]] || { echo "MQTT repository not found at: $MQTT_REPO"; exit 1; }

  if detect_requested_python; then
    echo "Python ${PYTHON_REQUEST} detected on the host: $(command -v "python${PYTHON_REQUEST}")"
  else
    echo "Python ${PYTHON_REQUEST} is not currently installed on the host."
    echo "The launcher will provision it inside uv automatically before creating the furniture venv."
  fi

  print_runtime_summary

  if [[ -z "$VIDEOCALL_DEVICE_API_KEY" ]]; then
    echo "Videocall device API key is required."
    exit 1
  fi

  if [[ "$AUTO_CONFIRM" != "1" ]] && ! ask_yes_no "Continue with this deployment plan" "y"; then
    log "WARN: Cancelled."
    exit 0
  fi

  if [[ "$reuse_existing_installation" == "1" ]]; then
    set_phase "reuse-existing-installation"
    log_section "[1/4] Reusing existing installation"
  else
    set_phase "prepare-environment"
    log_section "[1/4] Preparing environment"
    setup_environment
  fi

  set_phase "load-configuration"
  log_section "[2/4] Loading configuration"
  load_env_file

  set_phase "verify-configuration"
  log_section "[3/4] Verifying configuration"
  print_dry_run

  if [[ "$RUN_UPDATE_ONCE" == "1" ]]; then
    set_phase "update-once"
    log_section "[3b/4] Running one-shot update"
    run_update_once
  fi

  if [[ "$INSTALL_CRON" == "1" ]]; then
    set_phase "install-cron"
    log_section "[3c/4] Installing cron job"
    install_cron_job
  fi

  if [[ "$INSTALL_SYSTEMD_USER" == "1" ]]; then
    set_phase "install-systemd"
    log_section "[3d/4] Installing systemd user services"
    install_systemd_user_services
    set_phase "verify-systemd"
    log_section "[3e/4] Verifying systemd user services"
    verify_systemd_user_services
  fi

  set_phase "save-last-run-config"
  save_last_run_config

  set_phase "launch-runtime"
  log_section "[4/4] Launching furniture system"
  restart_software

  if [[ "$ENABLE_WATCH" == "1" ]]; then
    set_phase "watch-loop"
    log "Starting watch mode..."
    run_watch_loop
  fi
}

read_lock_pid() {
  if [[ -f "$LOCK_PID_FILE" ]]; then
    head -n1 "$LOCK_PID_FILE" 2>/dev/null | tr -dc '0-9'
  fi
}

discover_running_launcher_pid() {
  local candidate
  while IFS= read -r candidate; do
    if [[ -n "$candidate" && "$candidate" != "$$" && "$candidate" != "$PPID" ]]; then
      echo "$candidate"
      return 0
    fi
  done < <(pgrep -f "cobien-launcher.sh" 2>/dev/null || true)
  return 1
}

discover_running_launcher_pids() {
  local candidate
  while IFS= read -r candidate; do
    if [[ -n "$candidate" && "$candidate" != "$$" && "$candidate" != "$PPID" ]]; then
      echo "$candidate"
    fi
  done < <(pgrep -f "cobien-launcher.sh" 2>/dev/null || true)
}

is_running_inside_systemd_user_service() {
  [[ -n "${INVOCATION_ID:-}" ]]
}

has_active_systemd_user_launcher_service() {
  command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet cobien-launcher.service
}

stop_systemd_user_launcher_supervision() {
  if ! command -v systemctl >/dev/null 2>&1; then
    return 1
  fi

  log "Stopping systemd user launcher supervision before manual relaunch."
  systemctl --user stop cobien-update.timer >/dev/null 2>&1 || true
  systemctl --user stop cobien-update.service >/dev/null 2>&1 || true
  systemctl --user stop cobien-launcher.service >/dev/null 2>&1 || true
  sleep 1
  return 0
}

stop_all_other_launcher_processes() {
  local remaining_pid
  local stopped_any="0"
  while IFS= read -r remaining_pid; do
    [[ -z "$remaining_pid" ]] && continue
    if kill -0 "$remaining_pid" >/dev/null 2>&1; then
      log "Stopping extra launcher instance PID=$remaining_pid"
      kill -TERM "$remaining_pid" >/dev/null 2>&1 || true
      sleep 1
      if kill -0 "$remaining_pid" >/dev/null 2>&1; then
        kill -KILL "$remaining_pid" >/dev/null 2>&1 || true
      fi
      stopped_any="1"
    fi
  done < <(discover_running_launcher_pids)

  [[ "$stopped_any" == "1" ]] && sleep 1
  return 0
}

wait_for_no_other_launcher_processes() {
  local timeout_seconds="${1:-10}"
  local elapsed=0
  local running_pid=""

  while (( elapsed < timeout_seconds )); do
    running_pid="$(discover_running_launcher_pid || true)"
    if [[ -z "${running_pid:-}" ]]; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  running_pid="$(discover_running_launcher_pid || true)"
  if [[ -n "${running_pid:-}" ]]; then
    log "Launcher process still present after waiting ${timeout_seconds}s (PID=$running_pid)."
    return 1
  fi
  return 0
}

stabilize_launcher_takeover() {
  stop_systemd_user_launcher_supervision || true
  stop_all_other_launcher_processes || true
  wait_for_no_other_launcher_processes 10 || true
}

prepare_manual_launcher_takeover() {
  if is_running_inside_systemd_user_service; then
    return 0
  fi

  if ! has_active_systemd_user_launcher_service; then
    return 0
  fi

  log "systemd user service 'cobien-launcher.service' is active."
  if [[ "$FORCE_RESTART" == "1" ]]; then
    stop_systemd_user_launcher_supervision
    return 0
  fi

  if [[ "$NON_INTERACTIVE" != "1" ]] && ask_yes_no "Do you want the launcher to stop the active systemd user service before continuing" "y"; then
    stop_systemd_user_launcher_supervision
    return 0
  fi

  log "Exiting without changes. Stop 'cobien-launcher.service' or use --force-restart/--clean-launch."
  exit 0
}

stop_existing_launcher_instance() {
  local lock_pid
  lock_pid="$(read_lock_pid)"

  if [[ -z "${lock_pid:-}" ]]; then
    lock_pid="$(discover_running_launcher_pid || true)"
    if [[ -z "${lock_pid:-}" ]]; then
      log "Could not determine running launcher PID from lock file or process list."
      return 1
    fi
    log "Lock file PID unavailable, discovered running launcher PID=$lock_pid"
  fi

  if [[ "$lock_pid" == "$$" ]]; then
    log "Lock file points to current PID; refusing to stop self."
    return 1
  fi

  if ! kill -0 "$lock_pid" >/dev/null 2>&1; then
    log "Stale lock detected (PID $lock_pid not running). Trying process-list fallback."
    lock_pid="$(discover_running_launcher_pid || true)"
    if [[ -z "${lock_pid:-}" ]]; then
      return 0
    fi
    log "Fallback launcher PID discovered: $lock_pid"
  fi

  log "Stopping existing launcher instance PID=$lock_pid"
  kill -TERM "$lock_pid" >/dev/null 2>&1 || true

  local i
  for i in {1..10}; do
    if ! kill -0 "$lock_pid" >/dev/null 2>&1; then
      log "Existing launcher stopped."
      return 0
    fi
    sleep 1
  done

  log "Existing launcher did not stop in time; forcing kill."
  kill -KILL "$lock_pid" >/dev/null 2>&1 || true
  sleep 1
  if kill -0 "$lock_pid" >/dev/null 2>&1; then
    log "Failed to terminate existing launcher PID=$lock_pid"
    return 1
  fi

  stop_all_other_launcher_processes
  return 0
}

release_single_instance_lock() {
  if [[ -d "$LOCK_DIR" ]]; then
    rm -rf "$LOCK_DIR" || true
  fi
}

recover_stale_lock_state() {
  local running_pid
  running_pid="$(discover_running_launcher_pid || true)"
  if [[ -n "${running_pid:-}" ]]; then
    log "Another launcher PID appeared during lock recovery ($running_pid). Trying supervised takeover cleanup."
    stabilize_launcher_takeover
    running_pid="$(discover_running_launcher_pid || true)"
    if [[ -n "${running_pid:-}" ]]; then
      log "Lock recovery aborted: another launcher PID is still running ($running_pid)."
      return 1
    fi
  fi

  log "No launcher process remains; removing stale launcher lock directory: $LOCK_DIR"
  release_single_instance_lock
  rm -f "$LOCK_FILE" || true
  return 0
}

acquire_single_instance_lock() {
  mkdir -p "$(dirname "$LOCK_FILE")"
  : > "$LOCK_FILE"

  if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    local lock_pid
    lock_pid="$(read_lock_pid)"
    log "Another cobien-launcher instance is already running (PID=${lock_pid:-unknown})."

    if [[ -n "${lock_pid:-}" && "$lock_pid" == "$$" ]]; then
      log "Reusing existing single-instance lock owned by current PID=$$."
      trap release_single_instance_lock EXIT
      return 0
    fi

    if [[ "$FORCE_RESTART" == "1" ]]; then
      if stop_existing_launcher_instance; then
        sleep 1
        if ! mkdir "$LOCK_DIR" 2>/dev/null; then
          log "Lock still busy after stopping previous instance. Attempting stale-lock recovery."
          if ! recover_stale_lock_state || ! mkdir "$LOCK_DIR" 2>/dev/null; then
            log "Unable to acquire lock after stopping previous instance."
            exit 1
          fi
        fi
      else
        log "Unable to stop existing launcher instance."
        exit 1
      fi
    elif [[ "$NON_INTERACTIVE" != "1" ]] && ask_yes_no "Do you want to stop the previous launcher instance and continue" "y"; then
      if stop_existing_launcher_instance; then
        sleep 1
        if ! mkdir "$LOCK_DIR" 2>/dev/null; then
          log "Lock still busy after stopping previous instance. Attempting stale-lock recovery."
          if ! recover_stale_lock_state || ! mkdir "$LOCK_DIR" 2>/dev/null; then
            log "Unable to acquire lock after stopping previous instance."
            exit 1
          fi
        fi
      else
        log "Unable to stop existing launcher instance."
        exit 1
      fi
    else
      log "Exiting without changes. Use --force-restart to stop the existing instance automatically."
      exit 0
    fi
  fi

  printf '%s\n' "$$" >"$LOCK_PID_FILE" || true
  trap release_single_instance_lock EXIT
  log "Single-instance lock acquired: $LOCK_FILE"
}

save_last_run_config() {
  mkdir -p "$GLOBAL_CONFIG_DIR"
  cat > "$LAST_RUN_CONFIG_FILE" <<EOF
COBIEN_WORKSPACE_ROOT=$WORKSPACE_ROOT
COBIEN_FRONTEND_REPO_NAME=$FRONTEND_REPO_NAME
COBIEN_MQTT_REPO_NAME=$MQTT_REPO_NAME
COBIEN_MASTER_ENV_FILE=$MASTER_ENV_FILE
COBIEN_UPDATE_BRANCH=$BRANCH_NAME
COBIEN_UPDATE_REMOTE=$REMOTE_NAME
COBIEN_UPDATE_INTERVAL_SEC=$POLL_INTERVAL_SEC
COBIEN_APP_LANGUAGE=$APP_LANGUAGE
COBIEN_DEVICE_ID=$DEVICE_ID
COBIEN_VIDEOCALL_ROOM=$VIDEOCALL_ROOM
COBIEN_NOTIFY_API_KEY=$NOTIFY_API_KEY
COBIEN_VIDEOCALL_DEVICE_API_KEY=$VIDEOCALL_DEVICE_API_KEY
COBIEN_DEVICE_LOCATION=$DEVICE_LOCATION
COBIEN_HARDWARE_MODE=$HARDWARE_MODE
COBIEN_SETTINGS_PIN=$SETTINGS_PIN
COBIEN_RESTART_PIN=$RESTART_PIN
COBIEN_BACKEND_BASE_URL=$BACKEND_BASE_URL
COBIEN_DEVICE_POLL_URL=$DEVICE_POLL_URL
COBIEN_DEVICE_POLL_INTERVAL_SEC=$DEVICE_POLL_INTERVAL_SEC
COBIEN_DEVICE_HEARTBEAT_URL=$DEVICE_HEARTBEAT_URL
COBIEN_DEVICE_HEARTBEAT_INTERVAL_SEC=$DEVICE_HEARTBEAT_INTERVAL_SEC
COBIEN_PIZARRA_NOTIFY_URL=$PIZARRA_NOTIFY_URL
COBIEN_PIZARRA_API_URL=$PIZARRA_API_URL
COBIEN_PIZARRA_DELETE_URL_TEMPLATE=$PIZARRA_DELETE_URL_TEMPLATE
COBIEN_CONTACTS_API_URL=$CONTACTS_API_URL
COBIEN_ICSO_TELEMETRY_URL=$ICSO_TELEMETRY_URL
COBIEN_ICSO_EVENTS_URL=$ICSO_EVENTS_URL
COBIEN_DEVICE_VIDEOCALL_SESSION_URL=$DEVICE_VIDEOCALL_SESSION_URL
COBIEN_PORTAL_VIDEOCALL_URL=$PORTAL_VIDEOCALL_URL
COBIEN_PORTAL_VIDEOCALL_DEVICE_URL=$PORTAL_VIDEOCALL_DEVICE_URL
COBIEN_PORTAL_CALL_ANSWERED_URL=$PORTAL_CALL_ANSWERED_URL
COBIEN_MQTT_LOCAL_BROKER=$MQTT_LOCAL_BROKER
COBIEN_MQTT_LOCAL_PORT=$MQTT_LOCAL_PORT
COBIEN_HTTP_TIMEOUT=$HTTP_TIMEOUT_SEC
COBIEN_TTS_ENGINE=$TTS_ENGINE
COBIEN_TTS_PIPER_BIN=$TTS_PIPER_BIN
COBIEN_TTS_PIPER_MODEL_ES=$TTS_PIPER_MODEL_ES
COBIEN_TTS_PIPER_MODEL_FR=$TTS_PIPER_MODEL_FR
COBIEN_TTS_PIPER_MODEL_ES_MALE=$TTS_PIPER_MODEL_ES_MALE
COBIEN_TTS_PIPER_MODEL_ES_FEMALE=$TTS_PIPER_MODEL_ES_FEMALE
COBIEN_TTS_PIPER_MODEL_FR_MALE=$TTS_PIPER_MODEL_FR_MALE
COBIEN_TTS_PIPER_MODEL_FR_FEMALE=$TTS_PIPER_MODEL_FR_FEMALE
COBIEN_TTS_PIPER_MODEL_ES_URL=$TTS_PIPER_MODEL_ES_URL
COBIEN_TTS_PIPER_MODEL_FR_URL=$TTS_PIPER_MODEL_FR_URL
COBIEN_TTS_PIPER_MODEL_ES_MALE_URL=$TTS_PIPER_MODEL_ES_MALE_URL
COBIEN_TTS_PIPER_MODEL_ES_FEMALE_URL=$TTS_PIPER_MODEL_ES_FEMALE_URL
COBIEN_TTS_PIPER_MODEL_FR_MALE_URL=$TTS_PIPER_MODEL_FR_MALE_URL
COBIEN_TTS_PIPER_MODEL_FR_FEMALE_URL=$TTS_PIPER_MODEL_FR_FEMALE_URL
COBIEN_TTS_PIPER_VOICE_ES=$TTS_PIPER_VOICE_ES
COBIEN_TTS_PIPER_VOICE_FR=$TTS_PIPER_VOICE_FR
COBIEN_CRON_SCHEDULE=$CRON_SCHEDULE
COBIEN_INSTALL_SYSTEMD_USER=$INSTALL_SYSTEMD_USER
COBIEN_INSTALL_CRON=$INSTALL_CRON
COBIEN_ENABLE_WATCH=$ENABLE_WATCH
COBIEN_RECREATE_VENV=$RECREATE_VENV
COBIEN_INSTALL_SYSTEM_DEPS=$INSTALL_SYSTEM_DEPS
COBIEN_TTS_PIPER_PROVIDER=$TTS_PIPER_PROVIDER
COBIEN_TTS_PIPER_VERSION=$TTS_PIPER_VERSION
COBIEN_NON_INTERACTIVE=$NON_INTERACTIVE
COBIEN_AUTO_CONFIRM=$AUTO_CONFIRM
COBIEN_BOOTSTRAP_PYTHON_VERSION=$PYTHON_REQUEST
EOF
  log "Last run configuration saved to: $LAST_RUN_CONFIG_FILE"
}

load_last_run_config() {
  if [[ ! -f "$LAST_RUN_CONFIG_FILE" ]]; then
    return 1
  fi
  set -a
  source "$LAST_RUN_CONFIG_FILE"
  set +a

  WORKSPACE_ROOT="${COBIEN_WORKSPACE_ROOT:-$WORKSPACE_ROOT}"
  FRONTEND_REPO_NAME="${COBIEN_FRONTEND_REPO_NAME:-$FRONTEND_REPO_NAME}"
  MQTT_REPO_NAME="${COBIEN_MQTT_REPO_NAME:-$MQTT_REPO_NAME}"
  MASTER_ENV_FILE="${COBIEN_MASTER_ENV_FILE:-$MASTER_ENV_FILE}"
  BRANCH_NAME="${COBIEN_UPDATE_BRANCH:-$BRANCH_NAME}"
  REMOTE_NAME="${COBIEN_UPDATE_REMOTE:-$REMOTE_NAME}"
  POLL_INTERVAL_SEC="${COBIEN_UPDATE_INTERVAL_SEC:-$POLL_INTERVAL_SEC}"
  APP_LANGUAGE="${COBIEN_APP_LANGUAGE:-$APP_LANGUAGE}"
  DEVICE_ID="${COBIEN_DEVICE_ID:-$DEVICE_ID}"
  VIDEOCALL_ROOM="${COBIEN_VIDEOCALL_ROOM:-$VIDEOCALL_ROOM}"
  NOTIFY_API_KEY="${COBIEN_NOTIFY_API_KEY:-$NOTIFY_API_KEY}"
  VIDEOCALL_DEVICE_API_KEY="${COBIEN_VIDEOCALL_DEVICE_API_KEY:-$VIDEOCALL_DEVICE_API_KEY}"
  DEVICE_LOCATION="${COBIEN_DEVICE_LOCATION:-$DEVICE_LOCATION}"
  HARDWARE_MODE="${COBIEN_HARDWARE_MODE:-$HARDWARE_MODE}"
  SETTINGS_PIN="${COBIEN_SETTINGS_PIN:-$SETTINGS_PIN}"
  RESTART_PIN="${COBIEN_RESTART_PIN:-$RESTART_PIN}"
  WEATHER_CITIES_JSON="${COBIEN_WEATHER_CITIES_JSON:-$WEATHER_CITIES_JSON}"
  WEATHER_CITY_CATALOG_JSON="${COBIEN_WEATHER_CITY_CATALOG_JSON:-$WEATHER_CITY_CATALOG_JSON}"
  WEATHER_PRIMARY_CITY="${COBIEN_WEATHER_PRIMARY_CITY:-$WEATHER_PRIMARY_CITY}"
  BUTTON_COLORS_JSON="${COBIEN_BUTTON_COLORS_JSON:-$BUTTON_COLORS_JSON}"
  RFID_ACTIONS_JSON="${COBIEN_RFID_ACTIONS_JSON:-$RFID_ACTIONS_JSON}"
  MICROPHONE_DEVICE="${COBIEN_MICROPHONE_DEVICE:-$MICROPHONE_DEVICE}"
  AUDIO_OUTPUT_DEVICE="${COBIEN_AUDIO_OUTPUT_DEVICE:-$AUDIO_OUTPUT_DEVICE}"
  JOKE_CATEGORY="${COBIEN_JOKE_CATEGORY:-$JOKE_CATEGORY}"
  IDLE_TIMEOUT_SEC="${COBIEN_IDLE_TIMEOUT_SEC:-$IDLE_TIMEOUT_SEC}"
  NOTIFICATIONS_JSON="${COBIEN_NOTIFICATIONS_JSON:-$NOTIFICATIONS_JSON}"
  BACKEND_BASE_URL="${COBIEN_BACKEND_BASE_URL:-$BACKEND_BASE_URL}"
  DEVICE_POLL_URL="${COBIEN_DEVICE_POLL_URL:-$DEVICE_POLL_URL}"
  DEVICE_POLL_INTERVAL_SEC="${COBIEN_DEVICE_POLL_INTERVAL_SEC:-$DEVICE_POLL_INTERVAL_SEC}"
  DEVICE_HEARTBEAT_URL="${COBIEN_DEVICE_HEARTBEAT_URL:-$DEVICE_HEARTBEAT_URL}"
  DEVICE_HEARTBEAT_INTERVAL_SEC="${COBIEN_DEVICE_HEARTBEAT_INTERVAL_SEC:-$DEVICE_HEARTBEAT_INTERVAL_SEC}"
  OWM_API_KEY="${OWM_API_KEY:-$OWM_API_KEY}"
  NEWS_API_KEY="${NEWS_API_KEY:-$NEWS_API_KEY}"
  MONGO_URI="${MONGO_URI:-$MONGO_URI}"
  PIZARRA_NOTIFY_URL="${COBIEN_PIZARRA_NOTIFY_URL:-$PIZARRA_NOTIFY_URL}"
  PIZARRA_API_URL="${COBIEN_PIZARRA_API_URL:-$PIZARRA_API_URL}"
  PIZARRA_DELETE_URL_TEMPLATE="${COBIEN_PIZARRA_DELETE_URL_TEMPLATE:-$PIZARRA_DELETE_URL_TEMPLATE}"
  CONTACTS_API_URL="${COBIEN_CONTACTS_API_URL:-$CONTACTS_API_URL}"
  ICSO_TELEMETRY_URL="${COBIEN_ICSO_TELEMETRY_URL:-$ICSO_TELEMETRY_URL}"
  ICSO_EVENTS_URL="${COBIEN_ICSO_EVENTS_URL:-$ICSO_EVENTS_URL}"
  DEVICE_VIDEOCALL_SESSION_URL="${COBIEN_DEVICE_VIDEOCALL_SESSION_URL:-$DEVICE_VIDEOCALL_SESSION_URL}"
  PORTAL_VIDEOCALL_URL="${COBIEN_PORTAL_VIDEOCALL_URL:-$PORTAL_VIDEOCALL_URL}"
  PORTAL_VIDEOCALL_DEVICE_URL="${COBIEN_PORTAL_VIDEOCALL_DEVICE_URL:-$PORTAL_VIDEOCALL_DEVICE_URL}"
  PORTAL_CALL_ANSWERED_URL="${COBIEN_PORTAL_CALL_ANSWERED_URL:-$PORTAL_CALL_ANSWERED_URL}"
  MQTT_LOCAL_BROKER="${COBIEN_MQTT_LOCAL_BROKER:-$MQTT_LOCAL_BROKER}"
  MQTT_LOCAL_PORT="${COBIEN_MQTT_LOCAL_PORT:-$MQTT_LOCAL_PORT}"
  HTTP_TIMEOUT_SEC="${COBIEN_HTTP_TIMEOUT:-$HTTP_TIMEOUT_SEC}"
  TTS_ENGINE="${COBIEN_TTS_ENGINE:-$TTS_ENGINE}"
  TTS_RATE="${COBIEN_TTS_RATE:-$TTS_RATE}"
  TTS_VOLUME="${COBIEN_TTS_VOLUME:-$TTS_VOLUME}"
  TTS_PIPER_BIN="${COBIEN_TTS_PIPER_BIN:-$TTS_PIPER_BIN}"
  TTS_PIPER_MODEL_ES="${COBIEN_TTS_PIPER_MODEL_ES:-$TTS_PIPER_MODEL_ES}"
  TTS_PIPER_MODEL_FR="${COBIEN_TTS_PIPER_MODEL_FR:-$TTS_PIPER_MODEL_FR}"
  TTS_PIPER_MODEL_ES_MALE="${COBIEN_TTS_PIPER_MODEL_ES_MALE:-$TTS_PIPER_MODEL_ES_MALE}"
  TTS_PIPER_MODEL_ES_FEMALE="${COBIEN_TTS_PIPER_MODEL_ES_FEMALE:-$TTS_PIPER_MODEL_ES_FEMALE}"
  TTS_PIPER_MODEL_FR_MALE="${COBIEN_TTS_PIPER_MODEL_FR_MALE:-$TTS_PIPER_MODEL_FR_MALE}"
  TTS_PIPER_MODEL_FR_FEMALE="${COBIEN_TTS_PIPER_MODEL_FR_FEMALE:-$TTS_PIPER_MODEL_FR_FEMALE}"
  TTS_PIPER_MODEL_ES_URL="${COBIEN_TTS_PIPER_MODEL_ES_URL:-$TTS_PIPER_MODEL_ES_URL}"
  TTS_PIPER_MODEL_FR_URL="${COBIEN_TTS_PIPER_MODEL_FR_URL:-$TTS_PIPER_MODEL_FR_URL}"
  TTS_PIPER_MODEL_ES_MALE_URL="${COBIEN_TTS_PIPER_MODEL_ES_MALE_URL:-$TTS_PIPER_MODEL_ES_MALE_URL}"
  TTS_PIPER_MODEL_ES_FEMALE_URL="${COBIEN_TTS_PIPER_MODEL_ES_FEMALE_URL:-$TTS_PIPER_MODEL_ES_FEMALE_URL}"
  TTS_PIPER_MODEL_FR_MALE_URL="${COBIEN_TTS_PIPER_MODEL_FR_MALE_URL:-$TTS_PIPER_MODEL_FR_MALE_URL}"
  TTS_PIPER_MODEL_FR_FEMALE_URL="${COBIEN_TTS_PIPER_MODEL_FR_FEMALE_URL:-$TTS_PIPER_MODEL_FR_FEMALE_URL}"
  TTS_PIPER_VOICE_ES="${COBIEN_TTS_PIPER_VOICE_ES:-$TTS_PIPER_VOICE_ES}"
  TTS_PIPER_VOICE_FR="${COBIEN_TTS_PIPER_VOICE_FR:-$TTS_PIPER_VOICE_FR}"
  DISABLE_SYSTEM_SLEEP="${COBIEN_DISABLE_SYSTEM_SLEEP:-$DISABLE_SYSTEM_SLEEP}"
  OPENWEATHER_CURRENT_URL="${COBIEN_OPENWEATHER_CURRENT_URL:-$OPENWEATHER_CURRENT_URL}"
  OPENWEATHER_FORECAST_URL="${COBIEN_OPENWEATHER_FORECAST_URL:-$OPENWEATHER_FORECAST_URL}"
  NEWS_API_URL="${COBIEN_NEWS_API_URL:-$NEWS_API_URL}"
  OPEN_METEO_URL="${COBIEN_OPEN_METEO_URL:-$OPEN_METEO_URL}"
  NOMINATIM_SEARCH_URL="${COBIEN_NOMINATIM_SEARCH_URL:-$NOMINATIM_SEARCH_URL}"
  CRON_SCHEDULE="${COBIEN_CRON_SCHEDULE:-$CRON_SCHEDULE}"
  INSTALL_SYSTEMD_USER="${COBIEN_INSTALL_SYSTEMD_USER:-$INSTALL_SYSTEMD_USER}"
  INSTALL_CRON="${COBIEN_INSTALL_CRON:-$INSTALL_CRON}"
  ENABLE_WATCH="${COBIEN_ENABLE_WATCH:-$ENABLE_WATCH}"
  RECREATE_VENV="${COBIEN_RECREATE_VENV:-$RECREATE_VENV}"
  INSTALL_SYSTEM_DEPS="${COBIEN_INSTALL_SYSTEM_DEPS:-$INSTALL_SYSTEM_DEPS}"
  TTS_PIPER_PROVIDER="${COBIEN_TTS_PIPER_PROVIDER:-$TTS_PIPER_PROVIDER}"
  TTS_PIPER_VERSION="${COBIEN_TTS_PIPER_VERSION:-$TTS_PIPER_VERSION}"
  NON_INTERACTIVE="${COBIEN_NON_INTERACTIVE:-$NON_INTERACTIVE}"
  AUTO_CONFIRM="${COBIEN_AUTO_CONFIRM:-$AUTO_CONFIRM}"
  PYTHON_REQUEST="${COBIEN_BOOTSTRAP_PYTHON_VERSION:-$PYTHON_REQUEST}"
  normalize_device_identity
  set_service_defaults
  return 0
}

print_last_run_config_summary() {
  echo
  echo "Previous configuration found:"
  echo "  Workspace:        $WORKSPACE_ROOT"
  echo "  Frontend repo:    $FRONTEND_REPO_NAME"
  echo "  MQTT repo:        $MQTT_REPO_NAME"
  echo "  Branch:           $BRANCH_NAME"
  echo "  App language:     $APP_LANGUAGE"
  echo "  Device ID:        $DEVICE_ID"
  echo "  Videocall room:   $VIDEOCALL_ROOM"
  echo "  Backend base URL: $BACKEND_BASE_URL"
  echo "  Device poll URL:  $DEVICE_POLL_URL"
  echo "  Heartbeat URL:    $DEVICE_HEARTBEAT_URL"
  if [[ -n "$NOTIFY_API_KEY" ]]; then
    echo "  Notify key:       configured"
  else
    echo "  Notify key:       missing"
  fi
  if [[ -n "$VIDEOCALL_DEVICE_API_KEY" ]]; then
    echo "  Videocall key:    configured"
  else
    echo "  Videocall key:    missing"
  fi
  echo "  Device location:  $DEVICE_LOCATION"
  echo "  Hardware mode:    $HARDWARE_MODE"
  echo "  TTS engine:       $TTS_ENGINE"
  echo "  Cron schedule:    $CRON_SCHEDULE"
  echo "  Python request:   $PYTHON_REQUEST"
  echo
}

resolve_paths() {
  FRONTEND_REPO="$WORKSPACE_ROOT/$FRONTEND_REPO_NAME"
  MQTT_REPO="$WORKSPACE_ROOT/$MQTT_REPO_NAME"
  FRONTEND_APP_DIR="$FRONTEND_REPO/app"
  VENV_DIR="$FRONTEND_APP_DIR/.venv"
  ENV_FILE="${COBIEN_UPDATE_ENV_FILE:-$GLOBAL_CONFIG_DIR/cobien-update.env}"
  MASTER_ENV_FILE="${COBIEN_MASTER_ENV_FILE:-$LAUNCHER_ROOT/cobien.env}"
  BRIDGE_DIR="$MQTT_REPO/Interface_MQTT_CAN_c"
  CAN_CONFIG="$BRIDGE_DIR/conversion.json"
  SELF_SCRIPT="$LAUNCHER_ROOT/cobien-launcher.sh"
  FRONTEND_REPO_ROOT="$FRONTEND_REPO"
  LOG_DIR="${COBIEN_LOG_DIR:-$GLOBAL_STATE_DIR/logs}"
  MODELS_DIR="${COBIEN_MODELS_DIR:-$GLOBAL_DATA_DIR/models/piper}"
  PIPER_RUNTIME_DIR="${COBIEN_PIPER_RUNTIME_DIR:-$GLOBAL_DATA_DIR/piper/runtime}"
  RUNTIME_STATE_DIR="${COBIEN_RUNTIME_STATE_DIR:-$GLOBAL_STATE_DIR/runtime}"
  CACHE_DIR="${COBIEN_CACHE_DIR:-$GLOBAL_CACHE_DIR}"
  UPDATE_MARKER_FILE="$RUNTIME_STATE_DIR/system_updated.json"
  LAUNCHER_STOP_REQUEST_FILE="$RUNTIME_STATE_DIR/launcher_stop_requested.flag"
  MANUAL_UPDATE_RELOAD_FILE="$RUNTIME_STATE_DIR/manual_update_reload.flag"
}

derive_default_device_id() {
  local hostname_value
  hostname_value="$(hostname 2>/dev/null || echo "")"
  if [[ -n "$hostname_value" && "$hostname_value" =~ ([0-9]+)$ ]]; then
    echo "CoBien${BASH_REMATCH[1]}"
  else
    echo "CoBien1"
  fi
}

normalize_device_identity() {
  case "${APP_LANGUAGE,,}" in
    fr|french|francais|français) APP_LANGUAGE="fr" ;;
    *) APP_LANGUAGE="es" ;;
  esac
  if [[ -z "$DEVICE_ID" ]]; then
    DEVICE_ID="$(derive_default_device_id)"
  fi
  if [[ -z "$VIDEOCALL_ROOM" ]]; then
    VIDEOCALL_ROOM="$DEVICE_ID"
  fi
  if [[ -z "$DEVICE_LOCATION" ]]; then
    DEVICE_LOCATION="Bilbao"
  fi
  case "${HARDWARE_MODE,,}" in
    real|prod|production) HARDWARE_MODE="real" ;;
    mock|test|vm|virtual) HARDWARE_MODE="mock" ;;
    *) HARDWARE_MODE="auto" ;;
  esac
}

set_service_defaults() {
  [[ -z "$DEVICE_POLL_URL" ]] && DEVICE_POLL_URL="${BACKEND_BASE_URL%/}/pizarra/api/device/poll/"
  [[ -z "$DEVICE_HEARTBEAT_URL" ]] && DEVICE_HEARTBEAT_URL="${BACKEND_BASE_URL%/}/pizarra/api/devices/heartbeat/"
  [[ -z "$PIZARRA_NOTIFY_URL" ]] && PIZARRA_NOTIFY_URL="${BACKEND_BASE_URL%/}/pizarra/api/notify/"
  [[ -z "$PIZARRA_API_URL" ]] && PIZARRA_API_URL="${BACKEND_BASE_URL%/}/pizarra/api/messages/"
  [[ -z "$PIZARRA_DELETE_URL_TEMPLATE" ]] && PIZARRA_DELETE_URL_TEMPLATE="${BACKEND_BASE_URL%/}/pizarra/api/messages/{post_id}/delete/"
  [[ -z "$CONTACTS_API_URL" ]] && CONTACTS_API_URL="${BACKEND_BASE_URL%/}/pizarra/api/contacts/"
  [[ -z "$ICSO_TELEMETRY_URL" ]] && ICSO_TELEMETRY_URL="${BACKEND_BASE_URL%/}/pizarra/api/icso/telemetry/"
  [[ -z "$ICSO_EVENTS_URL" ]] && ICSO_EVENTS_URL="${BACKEND_BASE_URL%/}/pizarra/api/icso/events/"
  [[ -z "$PORTAL_VIDEOCALL_URL" ]] && PORTAL_VIDEOCALL_URL="${BACKEND_BASE_URL%/}/videocall/"
  [[ -z "$PORTAL_VIDEOCALL_DEVICE_URL" ]] && PORTAL_VIDEOCALL_DEVICE_URL="${BACKEND_BASE_URL%/}/videocall/device/"
  [[ -z "$DEVICE_VIDEOCALL_SESSION_URL" ]] && DEVICE_VIDEOCALL_SESSION_URL="${BACKEND_BASE_URL%/}/api/device-videocall-session/"
  [[ -z "$PORTAL_CALL_ANSWERED_URL" ]] && PORTAL_CALL_ANSWERED_URL="${BACKEND_BASE_URL%/}/api/call-answered/"
  return 0
}

load_master_env_if_present() {
  resolve_paths
  if [[ ! -f "$MASTER_ENV_FILE" ]]; then
    return 1
  fi

  log "Loading deployment env: $MASTER_ENV_FILE"
  set -a
  source "$MASTER_ENV_FILE"
  set +a

  WORKSPACE_ROOT="${COBIEN_WORKSPACE_ROOT:-$WORKSPACE_ROOT}"
  FRONTEND_REPO_NAME="${COBIEN_FRONTEND_REPO_NAME:-$FRONTEND_REPO_NAME}"
  MQTT_REPO_NAME="${COBIEN_MQTT_REPO_NAME:-$MQTT_REPO_NAME}"
  BRANCH_NAME="${COBIEN_UPDATE_BRANCH:-$BRANCH_NAME}"
  REMOTE_NAME="${COBIEN_UPDATE_REMOTE:-$REMOTE_NAME}"
  POLL_INTERVAL_SEC="${COBIEN_UPDATE_INTERVAL_SEC:-$POLL_INTERVAL_SEC}"
  APP_LANGUAGE="${COBIEN_APP_LANGUAGE:-$APP_LANGUAGE}"
  DEVICE_ID="${COBIEN_DEVICE_ID:-$DEVICE_ID}"
  VIDEOCALL_ROOM="${COBIEN_VIDEOCALL_ROOM:-$VIDEOCALL_ROOM}"
  NOTIFY_API_KEY="${COBIEN_NOTIFY_API_KEY:-$NOTIFY_API_KEY}"
  VIDEOCALL_DEVICE_API_KEY="${COBIEN_VIDEOCALL_DEVICE_API_KEY:-$VIDEOCALL_DEVICE_API_KEY}"
  DEVICE_LOCATION="${COBIEN_DEVICE_LOCATION:-$DEVICE_LOCATION}"
  HARDWARE_MODE="${COBIEN_HARDWARE_MODE:-$HARDWARE_MODE}"
  SETTINGS_PIN="${COBIEN_SETTINGS_PIN:-$SETTINGS_PIN}"
  RESTART_PIN="${COBIEN_RESTART_PIN:-$RESTART_PIN}"
  WEATHER_CITIES_JSON="${COBIEN_WEATHER_CITIES_JSON:-$WEATHER_CITIES_JSON}"
  WEATHER_CITY_CATALOG_JSON="${COBIEN_WEATHER_CITY_CATALOG_JSON:-$WEATHER_CITY_CATALOG_JSON}"
  WEATHER_PRIMARY_CITY="${COBIEN_WEATHER_PRIMARY_CITY:-$WEATHER_PRIMARY_CITY}"
  BUTTON_COLORS_JSON="${COBIEN_BUTTON_COLORS_JSON:-$BUTTON_COLORS_JSON}"
  RFID_ACTIONS_JSON="${COBIEN_RFID_ACTIONS_JSON:-$RFID_ACTIONS_JSON}"
  MICROPHONE_DEVICE="${COBIEN_MICROPHONE_DEVICE:-$MICROPHONE_DEVICE}"
  AUDIO_OUTPUT_DEVICE="${COBIEN_AUDIO_OUTPUT_DEVICE:-$AUDIO_OUTPUT_DEVICE}"
  JOKE_CATEGORY="${COBIEN_JOKE_CATEGORY:-$JOKE_CATEGORY}"
  IDLE_TIMEOUT_SEC="${COBIEN_IDLE_TIMEOUT_SEC:-$IDLE_TIMEOUT_SEC}"
  NOTIFICATIONS_JSON="${COBIEN_NOTIFICATIONS_JSON:-$NOTIFICATIONS_JSON}"
  BACKEND_BASE_URL="${COBIEN_BACKEND_BASE_URL:-$BACKEND_BASE_URL}"
  DEVICE_POLL_URL="${COBIEN_DEVICE_POLL_URL:-$DEVICE_POLL_URL}"
  DEVICE_POLL_INTERVAL_SEC="${COBIEN_DEVICE_POLL_INTERVAL_SEC:-$DEVICE_POLL_INTERVAL_SEC}"
  DEVICE_HEARTBEAT_URL="${COBIEN_DEVICE_HEARTBEAT_URL:-$DEVICE_HEARTBEAT_URL}"
  DEVICE_HEARTBEAT_INTERVAL_SEC="${COBIEN_DEVICE_HEARTBEAT_INTERVAL_SEC:-$DEVICE_HEARTBEAT_INTERVAL_SEC}"
  OWM_API_KEY="${OWM_API_KEY:-$OWM_API_KEY}"
  NEWS_API_KEY="${NEWS_API_KEY:-$NEWS_API_KEY}"
  MONGO_URI="${MONGO_URI:-$MONGO_URI}"
  PIZARRA_NOTIFY_URL="${COBIEN_PIZARRA_NOTIFY_URL:-$PIZARRA_NOTIFY_URL}"
  PIZARRA_API_URL="${COBIEN_PIZARRA_API_URL:-$PIZARRA_API_URL}"
  PIZARRA_DELETE_URL_TEMPLATE="${COBIEN_PIZARRA_DELETE_URL_TEMPLATE:-$PIZARRA_DELETE_URL_TEMPLATE}"
  CONTACTS_API_URL="${COBIEN_CONTACTS_API_URL:-$CONTACTS_API_URL}"
  ICSO_TELEMETRY_URL="${COBIEN_ICSO_TELEMETRY_URL:-$ICSO_TELEMETRY_URL}"
  ICSO_EVENTS_URL="${COBIEN_ICSO_EVENTS_URL:-$ICSO_EVENTS_URL}"
  DEVICE_VIDEOCALL_SESSION_URL="${COBIEN_DEVICE_VIDEOCALL_SESSION_URL:-$DEVICE_VIDEOCALL_SESSION_URL}"
  PORTAL_VIDEOCALL_URL="${COBIEN_PORTAL_VIDEOCALL_URL:-$PORTAL_VIDEOCALL_URL}"
  PORTAL_VIDEOCALL_DEVICE_URL="${COBIEN_PORTAL_VIDEOCALL_DEVICE_URL:-$PORTAL_VIDEOCALL_DEVICE_URL}"
  PORTAL_CALL_ANSWERED_URL="${COBIEN_PORTAL_CALL_ANSWERED_URL:-$PORTAL_CALL_ANSWERED_URL}"
  MQTT_LOCAL_BROKER="${COBIEN_MQTT_LOCAL_BROKER:-$MQTT_LOCAL_BROKER}"
  MQTT_LOCAL_PORT="${COBIEN_MQTT_LOCAL_PORT:-$MQTT_LOCAL_PORT}"
  HTTP_TIMEOUT_SEC="${COBIEN_HTTP_TIMEOUT:-$HTTP_TIMEOUT_SEC}"
  TTS_ENGINE="${COBIEN_TTS_ENGINE:-$TTS_ENGINE}"
  TTS_RATE="${COBIEN_TTS_RATE:-$TTS_RATE}"
  TTS_VOLUME="${COBIEN_TTS_VOLUME:-$TTS_VOLUME}"
  TTS_PIPER_BIN="${COBIEN_TTS_PIPER_BIN:-$TTS_PIPER_BIN}"
  TTS_PIPER_MODEL_ES="${COBIEN_TTS_PIPER_MODEL_ES:-$TTS_PIPER_MODEL_ES}"
  TTS_PIPER_MODEL_FR="${COBIEN_TTS_PIPER_MODEL_FR:-$TTS_PIPER_MODEL_FR}"
  TTS_PIPER_MODEL_ES_MALE="${COBIEN_TTS_PIPER_MODEL_ES_MALE:-$TTS_PIPER_MODEL_ES_MALE}"
  TTS_PIPER_MODEL_ES_FEMALE="${COBIEN_TTS_PIPER_MODEL_ES_FEMALE:-$TTS_PIPER_MODEL_ES_FEMALE}"
  TTS_PIPER_MODEL_FR_MALE="${COBIEN_TTS_PIPER_MODEL_FR_MALE:-$TTS_PIPER_MODEL_FR_MALE}"
  TTS_PIPER_MODEL_FR_FEMALE="${COBIEN_TTS_PIPER_MODEL_FR_FEMALE:-$TTS_PIPER_MODEL_FR_FEMALE}"
  TTS_PIPER_MODEL_ES_URL="${COBIEN_TTS_PIPER_MODEL_ES_URL:-$TTS_PIPER_MODEL_ES_URL}"
  TTS_PIPER_MODEL_FR_URL="${COBIEN_TTS_PIPER_MODEL_FR_URL:-$TTS_PIPER_MODEL_FR_URL}"
  TTS_PIPER_MODEL_ES_MALE_URL="${COBIEN_TTS_PIPER_MODEL_ES_MALE_URL:-$TTS_PIPER_MODEL_ES_MALE_URL}"
  TTS_PIPER_MODEL_ES_FEMALE_URL="${COBIEN_TTS_PIPER_MODEL_ES_FEMALE_URL:-$TTS_PIPER_MODEL_ES_FEMALE_URL}"
  TTS_PIPER_MODEL_FR_MALE_URL="${COBIEN_TTS_PIPER_MODEL_FR_MALE_URL:-$TTS_PIPER_MODEL_FR_MALE_URL}"
  TTS_PIPER_MODEL_FR_FEMALE_URL="${COBIEN_TTS_PIPER_MODEL_FR_FEMALE_URL:-$TTS_PIPER_MODEL_FR_FEMALE_URL}"
  TTS_PIPER_VOICE_ES="${COBIEN_TTS_PIPER_VOICE_ES:-$TTS_PIPER_VOICE_ES}"
  TTS_PIPER_VOICE_FR="${COBIEN_TTS_PIPER_VOICE_FR:-$TTS_PIPER_VOICE_FR}"
  DISABLE_SYSTEM_SLEEP="${COBIEN_DISABLE_SYSTEM_SLEEP:-$DISABLE_SYSTEM_SLEEP}"
  OPENWEATHER_CURRENT_URL="${COBIEN_OPENWEATHER_CURRENT_URL:-$OPENWEATHER_CURRENT_URL}"
  OPENWEATHER_FORECAST_URL="${COBIEN_OPENWEATHER_FORECAST_URL:-$OPENWEATHER_FORECAST_URL}"
  NEWS_API_URL="${COBIEN_NEWS_API_URL:-$NEWS_API_URL}"
  OPEN_METEO_URL="${COBIEN_OPEN_METEO_URL:-$OPEN_METEO_URL}"
  NOMINATIM_SEARCH_URL="${COBIEN_NOMINATIM_SEARCH_URL:-$NOMINATIM_SEARCH_URL}"
  normalize_device_identity
  set_service_defaults
  resolve_paths
  return 0
}

master_env_is_complete() {
  [[ -n "${DEVICE_ID:-}" ]] &&
  [[ -n "${VIDEOCALL_ROOM:-}" ]] &&
  [[ -n "${NOTIFY_API_KEY:-}" ]] &&
  [[ -n "${VIDEOCALL_DEVICE_API_KEY:-}" ]] &&
  [[ -n "${BACKEND_BASE_URL:-}" ]] &&
  [[ -n "${DEVICE_POLL_URL:-}" ]] &&
  [[ -n "${DEVICE_HEARTBEAT_URL:-}" ]] &&
  [[ -n "${PIZARRA_NOTIFY_URL:-}" ]] &&
  [[ -n "${PIZARRA_API_URL:-}" ]] &&
  [[ -n "${CONTACTS_API_URL:-}" ]] &&
  [[ -n "${ICSO_TELEMETRY_URL:-}" ]] &&
  [[ -n "${ICSO_EVENTS_URL:-}" ]] &&
  [[ -n "${DEVICE_VIDEOCALL_SESSION_URL:-}" ]] &&
  [[ -n "${PORTAL_VIDEOCALL_DEVICE_URL:-}" ]] &&
  [[ -n "${PORTAL_CALL_ANSWERED_URL:-}" ]]
}

validate_current_runtime_config() {
  local missing=()
  [[ -z "${DEVICE_ID:-}" ]] && missing+=("COBIEN_DEVICE_ID")
  [[ -z "${VIDEOCALL_ROOM:-}" ]] && missing+=("COBIEN_VIDEOCALL_ROOM")
  [[ -z "${NOTIFY_API_KEY:-}" ]] && missing+=("COBIEN_NOTIFY_API_KEY")
  [[ -z "${VIDEOCALL_DEVICE_API_KEY:-}" ]] && missing+=("COBIEN_VIDEOCALL_DEVICE_API_KEY")
  [[ -z "${BACKEND_BASE_URL:-}" ]] && missing+=("COBIEN_BACKEND_BASE_URL")
  [[ -z "${DEVICE_POLL_URL:-}" ]] && missing+=("COBIEN_DEVICE_POLL_URL")
  [[ -z "${DEVICE_HEARTBEAT_URL:-}" ]] && missing+=("COBIEN_DEVICE_HEARTBEAT_URL")
  [[ -z "${PIZARRA_NOTIFY_URL:-}" ]] && missing+=("COBIEN_PIZARRA_NOTIFY_URL")
  [[ -z "${PIZARRA_API_URL:-}" ]] && missing+=("COBIEN_PIZARRA_API_URL")
  [[ -z "${CONTACTS_API_URL:-}" ]] && missing+=("COBIEN_CONTACTS_API_URL")
  [[ -z "${ICSO_TELEMETRY_URL:-}" ]] && missing+=("COBIEN_ICSO_TELEMETRY_URL")
  [[ -z "${ICSO_EVENTS_URL:-}" ]] && missing+=("COBIEN_ICSO_EVENTS_URL")
  [[ -z "${DEVICE_VIDEOCALL_SESSION_URL:-}" ]] && missing+=("COBIEN_DEVICE_VIDEOCALL_SESSION_URL")
  [[ -z "${PORTAL_VIDEOCALL_DEVICE_URL:-}" ]] && missing+=("COBIEN_PORTAL_VIDEOCALL_DEVICE_URL")
  [[ -z "${PORTAL_CALL_ANSWERED_URL:-}" ]] && missing+=("COBIEN_PORTAL_CALL_ANSWERED_URL")

  if (( ${#missing[@]} > 0 )); then
    log "ERROR: Missing required CoBien configuration:"
    local key
    for key in "${missing[@]}"; do
      log "  - $key"
    done
    log "Provide the missing values in the launcher cobien.env file or pass them explicitly to the launcher."
    return 1
  fi
  return 0
}

setup_can_bus() {
  log "CAN: Initializing the CAN bus"
  sudo -n /sbin/ip link set can0 down
  sudo -n /sbin/ip link set can0 type can bitrate "${COBIEN_CAN_BITRATE:-500000}"
  sudo -n /sbin/ip link set can0 up
}

can_hardware_available() {
  ip link show can0 >/dev/null 2>&1
}

should_enable_hardware_runtime() {
  case "${HARDWARE_MODE,,}" in
    mock|test|vm|virtual)
      return 1
      ;;
    real|prod|production)
      return 0
      ;;
    auto|*)
      if can_hardware_available; then
        return 0
      fi
      return 1
      ;;
  esac
}

start_can_logger_background() {
  if [[ "$CAN_LOG_ENABLE" != "1" ]]; then
    log "CAN: Logging disabled (COBIEN_CAN_LOG_ENABLE=$CAN_LOG_ENABLE)"
    return 0
  fi

  if ! command -v candump >/dev/null 2>&1; then
    log "WARN: CAN: candump not available; skipping CAN logging"
    return 0
  fi

  cleanup_old_logs "can-bus"
  local can_log_file
  can_log_file="$(build_dated_log_path "can-bus")"
  printf '[%s] [CAN] Starting candump on can0\n' "$(date '+%Y-%m-%d %H:%M:%S')" >>"$can_log_file"
  pkill -f "candump can0" >/dev/null 2>&1 || true
  nohup candump can0 2>&1 | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' >>"$can_log_file" &
  log "CAN: Logging CAN traffic to: $can_log_file"
}

runtime_bridge_command() {
  cat <<EOF
echo '[BRIDGE] Build and launch'
set -e
cd "$BRIDGE_DIR" || exit
make clean
make -j
./cobien_bridge "$CAN_CONFIG"
EOF
}

runtime_app_command() {
  cat <<EOF
echo '[APP] Launching frontend with uv'
cd "$FRONTEND_APP_DIR" || exit
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
fi
if command -v "$UV_BIN" >/dev/null 2>&1; then
  "$UV_BIN" run --python "$PYTHON_REQUEST" --project "$FRONTEND_APP_DIR" mainApp.py
else
  echo '[APP] uv not found, using fallback Python'
  if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
  fi
  "$PYTHON_BIN" mainApp.py
fi
EOF
}

runtime_can_open_terminals() {
  [[ -n "${DISPLAY:-}" ]] && command -v gnome-terminal >/dev/null 2>&1
}

runtime_launch_named_terminal() {
  local title="$1"
  local command_text="$2"
  if runtime_can_open_terminals; then
    gnome-terminal --title="$title" -- bash -lc "$command_text" || return 1
    return 0
  fi
  return 1
}

runtime_launch_background() {
  local name="$1"
  local command_text="$2"
  local log_file
  log_file="$(build_dated_log_path "$name")"
  cleanup_old_logs "$name"
  log "FALLBACK: Launching $name in background. Log: $log_file"
  printf '[%s] [%s] Starting background command\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$name" >>"$log_file"
  nohup bash -lc "$command_text" 2>&1 | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' >>"$log_file" &
}

build_dated_log_path() {
  local name="$1"
  local stamp
  stamp="$(date +%Y%m%d)"
  echo "$LOG_DIR/${name}-${stamp}.log"
}

cleanup_old_logs() {
  local name="$1"
  if [[ -d "$LOG_DIR" ]]; then
    find "$LOG_DIR" -maxdepth 1 -type f -name "${name}-*.log" -mtime +"$LOG_RETENTION_DAYS" -delete >/dev/null 2>&1 || true
  fi
}

close_runtime_windows() {
  if ! command -v wmctrl >/dev/null 2>&1; then
    return 0
  fi
  for title in "MQTT-CAN BRIDGE" "COBIEN APP"; do
    while IFS= read -r window_id; do
      [[ -n "${window_id:-}" ]] || continue
      wmctrl -ic "$window_id" >/dev/null 2>&1 || true
    done < <(wmctrl -l 2>/dev/null | awk -v title="$title" '$0 ~ title {print $1}')
  done
}

stop_runtime_processes() {
  pkill -f "candump can0" >/dev/null 2>&1 || true
  pkill -f "/cobien_bridge" >/dev/null 2>&1 || true
  pkill -f "mainApp.py" >/dev/null 2>&1 || true
  pkill -f "uv run --python .* mainApp.py" >/dev/null 2>&1 || true
  pkill -f "\\[APP\\] Launching frontend with uv" >/dev/null 2>&1 || true
  pkill -f "\\[BRIDGE\\] Build and launch" >/dev/null 2>&1 || true
  pkill -f "\\[CAN\\] Initializing the CAN bus" >/dev/null 2>&1 || true
}

wait_for_runtime_shutdown() {
  local timeout_seconds="${1:-12}"
  local elapsed=0
  local running_count="0"

  while (( elapsed < timeout_seconds )); do
    running_count="$(count_running_runtime_processes | tr -d '[:space:]')"
    if [[ "${running_count:-0}" == "0" ]]; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  running_count="$(count_running_runtime_processes | tr -d '[:space:]')"
  if [[ "${running_count:-0}" != "0" ]]; then
    log "WARN: Runtime processes still present after waiting ${timeout_seconds}s (${running_count} remaining)."
    return 1
  fi
  return 0
}

count_running_runtime_processes() {
  local matches
  matches="$(pgrep -af "candump can0|/cobien_bridge|mainApp.py|\\[APP\\] Launching frontend with uv|\\[BRIDGE\\] Build and launch|\\[CAN\\] Initializing the CAN bus" || true)"
  if [[ -z "${matches//[[:space:]]/}" ]]; then
    echo 0
    return
  fi
  printf '%s\n' "$matches" | wc -l
}

perform_preflight_runtime_cleanup() {
  local running_count
  running_count="$(count_running_runtime_processes | tr -d '[:space:]')"
  if [[ "${running_count:-0}" -gt 0 ]]; then
    log "CLEAN: Preflight detected ${running_count} existing runtime process(es). Cleaning before relaunch..."
  else
    log "CLEAN: Preflight detected no previous runtime processes."
  fi
  close_runtime_windows
  stop_runtime_processes
  wait_for_runtime_shutdown 12 || true
  close_runtime_windows
}

clear_launcher_stop_request() {
  if [[ -n "${LAUNCHER_STOP_REQUEST_FILE:-}" && -f "$LAUNCHER_STOP_REQUEST_FILE" ]]; then
    rm -f "$LAUNCHER_STOP_REQUEST_FILE" >/dev/null 2>&1 || true
  fi
}

clear_manual_update_reload_request() {
  if [[ -n "${MANUAL_UPDATE_RELOAD_FILE:-}" && -f "$MANUAL_UPDATE_RELOAD_FILE" ]]; then
    rm -f "$MANUAL_UPDATE_RELOAD_FILE" >/dev/null 2>&1 || true
  fi
}

is_manual_update_reload_requested() {
  [[ -n "${MANUAL_UPDATE_RELOAD_FILE:-}" && -f "$MANUAL_UPDATE_RELOAD_FILE" ]]
}

is_launcher_stop_requested() {
  [[ -n "${LAUNCHER_STOP_REQUEST_FILE:-}" && -f "$LAUNCHER_STOP_REQUEST_FILE" ]]
}

is_frontend_runtime_running() {
  pgrep -f "mainApp.py|uv run --python .* mainApp.py|\\[APP\\] Launching frontend with uv" >/dev/null 2>&1
}

launch_runtime() {
  local relaunch_after_update="${1:-0}"
  set_phase "launch-runtime"
  log_phase_banner "Runtime launch" "Building the final runtime state and starting the furniture application."
  check_paths
  validate_runtime_file_dependencies
  normalize_device_identity
  ensure_runtime_dependencies
  configure_tts_runtime
  ensure_device_identity_config
  configure_audio_input_defaults
  resolve_python_bin
  resolve_uv_bin
  mkdir -p "$LOG_DIR"
  animate_status "Starting runtime services"
  ensure_mosquitto_running
  clear_launcher_stop_request

  log_section "Launching CoBien System"
  log "PATHS: FRONTEND_REPO_ROOT=$FRONTEND_REPO_ROOT"
  log "PATHS: MQTT_REPO=$MQTT_REPO"
  log "PATHS: BRIDGE_DIR=$BRIDGE_DIR"
  log "PATHS: UV_BIN=$UV_BIN"
  log "PATHS: FRONTEND_APP_DIR=$FRONTEND_APP_DIR"
  log "PATHS: LOG_DIR=$LOG_DIR"
  if runtime_can_open_terminals; then
    log "TERM: gnome-terminal available on DISPLAY=${DISPLAY:-}"
  else
    log "WARN: TERM: No graphical terminal available, using fallback mode"
  fi

  if [[ "$relaunch_after_update" == "1" ]]; then
    log "CLEAN: Update relaunch detected."
  else
    log "CLEAN: Standard launch detected."
  fi
  perform_preflight_runtime_cleanup

  if should_enable_hardware_runtime; then
    log "Hardware runtime enabled (mode=$HARDWARE_MODE)"
    setup_can_bus
    start_can_logger_background
  else
    log "WARN: Hardware runtime disabled (mode=$HARDWARE_MODE). Skipping CAN setup/logger/bridge."
  fi

  sleep 2

  if should_enable_hardware_runtime; then
    runtime_launch_background "mqtt-can-bridge" "$(runtime_bridge_command)"
  fi

  sleep 2

  runtime_launch_background "cobien-app" "$(runtime_app_command)"
}

ensure_runtime_supervision() {
  if is_launcher_stop_requested; then
    if is_frontend_runtime_running; then
      log "KIOSK: stop requested but runtime still active."
    else
      log "KIOSK: runtime intentionally stopped from administration; waiting for manual relaunch."
    fi
    return 0
  fi

  if is_frontend_runtime_running; then
    return 0
  fi

  log "KIOSK: frontend runtime is not running; relaunching immediately."
  launch_runtime 0
}

run_passive_supervision_loop() {
  log "Passive supervision enabled; update checks are delegated to external triggers."
  while true; do
    ensure_runtime_supervision
    sleep 2
  done
}

ask() {
  local prompt="$1"
  local default_value="${2:-}"
  local answer
  if [[ "$NON_INTERACTIVE" == "1" ]]; then
    echo "$default_value"
    return
  fi
  while true; do
    if [[ -n "$default_value" ]]; then
      if ! tty_read 0 "$prompt [$default_value]: " answer; then
        echo
        echo "$default_value"
        return
      fi
      answer="${answer:-$default_value}"
    else
      if ! tty_read 0 "$prompt: " answer; then
        echo
        echo ""
        return
      fi
    fi
    answer="${answer#"${answer%%[![:space:]]*}"}"
    answer="${answer%"${answer##*[![:space:]]}"}"
    echo "$answer"
    return
  done
}

ask_secret_required() {
  local prompt="$1"
  local current_value="${2:-}"
  local answer=""
  if [[ "$NON_INTERACTIVE" == "1" ]]; then
    echo "$current_value"
    return
  fi
  while true; do
    if ! tty_read 1 "$prompt: " answer; then
      echo
      if [[ -n "${current_value//[[:space:]]/}" ]]; then
        echo "$current_value"
        return
      fi
      echo "This value is required."
      return 1
    fi
    echo
    if [[ -n "${answer//[[:space:]]/}" ]]; then
      echo "$answer"
      return
    fi
    echo "This value is required."
  done
}

ask_yes_no() {
  local prompt="$1"
  local default_value="${2:-y}"
  local suffix="[Y/n]"
  local answer

  if [[ "$default_value" == "n" ]]; then
    suffix="[y/N]"
  else
    suffix="[Y/n]"
  fi

  if [[ "$NON_INTERACTIVE" == "1" ]]; then
    [[ "$default_value" != "n" ]]
    return
  fi

  while true; do
    if ! tty_read 0 "$prompt $suffix: " answer; then
      echo
      [[ "$default_value" != "n" ]]
      return
    fi
    answer="${answer:-$default_value}"
    case "${answer,,}" in
      y|yes|s|si|sí) return 0 ;;
      n|no) return 1 ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

ask_menu_choice() {
  local prompt="$1"
  local default_value="$2"
  shift 2
  local options=("$@")
  local answer=""
  local valid_choices=()

  if [[ "$NON_INTERACTIVE" == "1" ]]; then
    echo "$default_value"
    return
  fi

  printf '%s\n' "$prompt" >&2
  local option
  for option in "${options[@]}"; do
    printf '  %s\n' "$option" >&2
    valid_choices+=("${option%%.*}")
  done

  while true; do
    if ! tty_read 0 "Choose an option [$default_value]: " answer; then
      echo
      echo "$default_value"
      return
    fi
    answer="${answer:-$default_value}"
    local choice
    for choice in "${valid_choices[@]}"; do
      if [[ "$answer" == "$choice" ]]; then
        echo "$answer"
        return
      fi
    done
    echo "Please choose one of: ${valid_choices[*]}"
  done
}

detect_requested_python() {
  command -v "python${PYTHON_REQUEST}" >/dev/null 2>&1
}

detect_python311() {
  command -v python3.11 >/dev/null 2>&1
}

detect_python_fallback() {
  command -v python3.12 >/dev/null 2>&1 || command -v python3.11 >/dev/null 2>&1
}

python_fallback_bin() {
  if command -v python3.12 >/dev/null 2>&1; then echo "python3.12"
  elif command -v python3.11 >/dev/null 2>&1; then echo "python3.11"
  fi
}

python_fallback_apt_pkg() {
  if apt-cache show python3.12 >/dev/null 2>&1; then echo "3.12"
  elif apt-cache show python3.11 >/dev/null 2>&1; then echo "3.11"
  fi
}

check_paths() {
  set_phase "check-paths"
  resolve_paths
  mkdir -p "$GLOBAL_CONFIG_DIR" "$GLOBAL_STATE_DIR" "$GLOBAL_CACHE_DIR" "$GLOBAL_DATA_DIR" "$LOG_DIR" "$RUNTIME_STATE_DIR" "$CACHE_DIR" "$MODELS_DIR" "$PIPER_RUNTIME_DIR"
  [[ -d "$FRONTEND_REPO/.git" ]] || { log "Frontend repository not found: $FRONTEND_REPO"; exit 1; }
  [[ -d "$MQTT_REPO/.git" ]] || { log "MQTT repository not found: $MQTT_REPO"; exit 1; }
  [[ -d "$FRONTEND_APP_DIR" ]] || { log "Frontend app directory not found: $FRONTEND_APP_DIR"; exit 1; }
  [[ -d "$BRIDGE_DIR" ]] || { log "Bridge directory not found: $BRIDGE_DIR"; exit 1; }
  [[ -f "$SELF_SCRIPT" ]] || { log "Launcher script not found: $SELF_SCRIPT"; exit 1; }
  [[ -f "$FRONTEND_APP_DIR/mainApp.py" ]] || { log "Frontend entrypoint missing: $FRONTEND_APP_DIR/mainApp.py"; exit 1; }
  [[ -f "$FRONTEND_APP_DIR/pyproject.toml" ]] || { log "Pyproject missing: $FRONTEND_APP_DIR/pyproject.toml"; exit 1; }
  [[ -f "$FRONTEND_APP_DIR/config/config.default.json" ]] || { log "Default unified config missing: $FRONTEND_APP_DIR/config/config.default.json"; exit 1; }
  [[ -f "$FRONTEND_APP_DIR/config_runtime.py" ]] || { log "Launcher config contract missing: $FRONTEND_APP_DIR/config_runtime.py"; exit 1; }
  [[ -f "$FRONTEND_APP_DIR/VERSION" ]] || { log "Version file missing: $FRONTEND_APP_DIR/VERSION"; exit 1; }
  [[ -f "$CAN_CONFIG" ]] || { log "CAN conversion config missing: $CAN_CONFIG"; exit 1; }
  [[ -f "$BRIDGE_DIR/Makefile" ]] || { log "Bridge Makefile missing: $BRIDGE_DIR/Makefile"; exit 1; }
}

validate_runtime_file_dependencies() {
  set_phase "validate-runtime-files"
  check_paths
  local service_dir="$LAUNCHER_ROOT/systemd"
  [[ -f "$service_dir/cobien-launcher.service" ]] || { log "systemd launcher unit missing: $service_dir/cobien-launcher.service"; exit 1; }
  [[ -f "$service_dir/cobien-update.service" ]] || { log "systemd update unit missing: $service_dir/cobien-update.service"; exit 1; }
  [[ -f "$service_dir/cobien-update.timer" ]] || { log "systemd update timer missing: $service_dir/cobien-update.timer"; exit 1; }
  [[ -f "$LAUNCHER_ROOT/import-systemd-user-env.sh" ]] || { log "session env import helper missing: $LAUNCHER_ROOT/import-systemd-user-env.sh"; exit 1; }
}

can_perform_privileged_installs() {
  [[ "$MODE" == "setup" ]] && ! is_running_inside_systemd_user_service
}

checkout_branch() {
  local repo="$1"
  git -C "$repo" checkout "$BRANCH_NAME"
}

install_system_deps_fn() {
  if [[ "$INSTALL_SYSTEM_DEPS" != "1" ]]; then
    log "Skipping system dependencies"
    return
  fi

  log_phase_banner "System dependencies" "Installing OS packages required by the launcher, audio stack, GTK/WebRTC runtime and build tools."
  animate_status "Refreshing apt metadata"
  sudo apt update
  animate_status "Installing base runtime packages"
  sudo apt install -y \
    git curl wget build-essential cmake pkg-config \
    python3 python3-venv python3-pip \
    wmctrl gnome-terminal can-utils iproute2 xclip xsel \
    alsa-utils \
    pulseaudio-utils pipewire-pulse wireplumber pavucontrol \
    mosquitto mosquitto-clients \
    libasound2-dev portaudio19-dev \
    libgl1 libegl1 libglib2.0-0 \
    libgstreamer1.0-0 gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-libav \
    libpulse0 libmosquitto-dev libcjson-dev \
    libxkbcommon-x11-0 libxcb-cursor0 libxcb-icccm4 \
    libxcb-keysyms1 libxcb-render-util0 libxcb-xinerama0 \
    libxcomposite1 libxdamage1 libxrandr2 libnss3 \
    libatk-bridge2.0-0 libgtk-3-0
  log "OK: System dependencies installed. Python runtime version selection is handled by uv."
}

ensure_runtime_dependencies() {
  local missing_packages=()
  local apt_updated="0"

  command -v git >/dev/null 2>&1 || missing_packages+=("git")
  command -v curl >/dev/null 2>&1 || missing_packages+=("curl")
  command -v wget >/dev/null 2>&1 || missing_packages+=("wget")
  command -v make >/dev/null 2>&1 || missing_packages+=("build-essential")
  command -v gcc >/dev/null 2>&1 || missing_packages+=("build-essential")
  command -v cmake >/dev/null 2>&1 || missing_packages+=("cmake")
  command -v candump >/dev/null 2>&1 || missing_packages+=("can-utils")
  command -v ip >/dev/null 2>&1 || missing_packages+=("iproute2")
  command -v xclip >/dev/null 2>&1 || missing_packages+=("xclip")
  command -v xsel >/dev/null 2>&1 || missing_packages+=("xsel")
  command -v aplay >/dev/null 2>&1 || missing_packages+=("alsa-utils")
  command -v pactl >/dev/null 2>&1 || missing_packages+=("pulseaudio-utils")
  dpkg -s pipewire-pulse >/dev/null 2>&1 || missing_packages+=("pipewire-pulse")
  dpkg -s wireplumber >/dev/null 2>&1 || missing_packages+=("wireplumber")
  command -v mosquitto >/dev/null 2>&1 || missing_packages+=("mosquitto" "mosquitto-clients")

  if [[ "${#missing_packages[@]}" -gt 0 ]]; then
    log "Missing runtime dependencies detected: ${missing_packages[*]}"
    if ! can_perform_privileged_installs; then
      log "ERROR: Missing runtime dependencies cannot be installed during '$MODE'."
      log "ERROR: Re-run setup-cobien-furniture-environment.sh so the installer can prepare the system before reboot."
      return 1
    fi
    log "Installing missing runtime dependencies (sudo may ask for password)..."
    sudo apt update
    apt_updated="1"
    sudo apt install -y "${missing_packages[@]}"
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    if ! can_perform_privileged_installs; then
      log "ERROR: Python 3 base runtime is missing and cannot be installed during '$MODE'."
      log "ERROR: Re-run setup-cobien-furniture-environment.sh to complete the installation."
      return 1
    fi
    log "Python 3 base runtime missing. Installing generic python3 package so uv can bootstrap the requested interpreter."
    if [[ "$apt_updated" != "1" ]]; then sudo apt update; apt_updated="1"; fi
    sudo apt install -y python3 python3-venv python3-pip
  fi
}

configure_tts_runtime() {
  install_piper_runtime_binary() {
    local release_tag="${COBIEN_TTS_PIPER_RELEASE_TAG:-$TTS_PIPER_RELEASE_TAG_DEFAULT}"
    local machine archive_name runtime_dir archive_path download_url extracted_dir
    machine="$(uname -m)"
    case "$machine" in
      x86_64|amd64) archive_name="piper_linux_x86_64.tar.gz" ;;
      aarch64|arm64) archive_name="piper_linux_aarch64.tar.gz" ;;
      armv7l|armv7) archive_name="piper_linux_armv7l.tar.gz" ;;
      *)
        log "WARN: Unsupported architecture for automatic Piper binary install: $machine"
        return 1
        ;;
    esac

    runtime_dir="$PIPER_RUNTIME_DIR"
    archive_path="$runtime_dir/$archive_name"
    download_url="https://github.com/rhasspy/piper/releases/download/${release_tag}/${archive_name}"
    mkdir -p "$runtime_dir"

    log "Downloading Piper runtime from: $download_url"
    if ! download_file "$download_url" "$archive_path"; then
      rm -f "$archive_path" || true
      log "Failed to download Piper runtime archive."
      return 1
    fi

    rm -rf "$runtime_dir/piper" || true
    if ! tar -xzf "$archive_path" -C "$runtime_dir"; then
      log "Failed to extract Piper runtime archive."
      return 1
    fi

    extracted_dir="$runtime_dir/piper"
    if [[ -x "$extracted_dir/piper" ]]; then
      TTS_PIPER_BIN="$extracted_dir/piper"
      TTS_PIPER_PROVIDER="user"
      TTS_PIPER_VERSION="$($TTS_PIPER_BIN --version 2>/dev/null | sed -n '1p' || true)"
      log "Piper runtime installed at: $TTS_PIPER_BIN"
      return 0
    fi

    log "Piper runtime archive extracted but binary was not found."
    return 1
  }

  install_piper_system_binary() {
    local arch asset asset_url extract_dir asset_tmp piper_found dest_bin
    arch="$(uname -m)"
    case "$arch" in
      x86_64|amd64) asset="piper_linux_x86_64.tar.gz" ;;
      aarch64|arm64) asset="piper_linux_aarch64.tar.gz" ;;
      armv7l|armv7) asset="piper_linux_armv7l.tar.gz" ;;
      *) asset="piper_linux_x86_64.tar.gz" ;;
    esac
    asset_url="https://github.com/rhasspy/piper/releases/download/${TTS_PIPER_RELEASE_TAG_DEFAULT}/${asset}"
    extract_dir="$(mktemp -d)"
    asset_tmp="$extract_dir/$asset"

    log "Attempting system install of Piper from: $asset_url"
    if ! download_file "$asset_url" "$asset_tmp"; then
      log "Failed to download Piper release for system install"
      rm -rf "$extract_dir" || true
      return 1
    fi

    if ! tar -xzf "$asset_tmp" -C "$extract_dir" >/dev/null 2>&1; then
      log "Failed to extract Piper system archive"
      rm -rf "$extract_dir" || true
      return 1
    fi

    piper_found="$(find "$extract_dir" -type f -name piper -perm /111 | head -n1 || true)"
    if [[ -z "$piper_found" ]]; then
      log "Piper executable not found inside system archive"
      rm -rf "$extract_dir" || true
      return 1
    fi

    dest_bin="/usr/local/bin/piper"
    if sudo sh -c "mkdir -p /usr/local/bin && cp '$piper_found' '$dest_bin' && chmod +x '$dest_bin'"; then
      log "Piper installed to: $dest_bin"
      TTS_PIPER_BIN="$dest_bin"
      TTS_PIPER_PROVIDER="system"
      TTS_PIPER_VERSION="$($TTS_PIPER_BIN --version 2>/dev/null | sed -n '1p' || true)"
      rm -rf "$extract_dir" || true
      return 0
    else
      log "Failed to install Piper to /usr/local/bin (sudo failed)"
      rm -rf "$extract_dir" || true
      return 1
    fi
  }

  download_file() {
    local url="$1"
    local out_file="$2"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$url" -o "$out_file"
      return $?
    fi
    if command -v wget >/dev/null 2>&1; then
      wget -qO "$out_file" "$url"
      return $?
    fi
    return 1
  }

  install_piper_via_snap() {
    # Try to install piper-tts using snap (preferred for persistence)
    if ! command -v snap >/dev/null 2>&1; then
      log "snap not found; attempting to install snapd via apt"
      sudo apt update || true
      sudo apt install -y snapd || return 1
      # allow snapd to setup
      sleep 1
    fi

    if snap list piper-tts >/dev/null 2>&1; then
      log "snap: piper-tts already installed"
    else
      log "Installing piper-tts via snap (requires sudo)"
      if ! sudo snap install piper-tts; then
        log "snap: failed to install piper-tts"
        return 1
      fi
    fi

    # detect piper binary path from snap
    if command -v piper >/dev/null 2>&1; then
      TTS_PIPER_BIN="$(command -v piper)"
      TTS_PIPER_PROVIDER="snap"
      TTS_PIPER_VERSION="$(piper --version 2>/dev/null | sed -n '1p' || true)"
      return 0
    fi
    if [[ -x "/snap/bin/piper" ]]; then
      TTS_PIPER_BIN="/snap/bin/piper"
      TTS_PIPER_PROVIDER="snap"
      TTS_PIPER_VERSION="$($TTS_PIPER_BIN --version 2>/dev/null | sed -n '1p' || true)"
      return 0
    fi
    return 1
  }

  install_piper_model() {
    local lang="$1"
    local model_path="$2"
    local model_url="$3"
    local model_dir model_tmp config_path config_url config_tmp
    model_dir="$(dirname "$model_path")"
    config_path="${model_path}.json"
    config_url="${model_url}.json"
    mkdir -p "$model_dir"

    if [[ -z "$model_url" ]]; then
      log "Piper $lang model URL is empty and model assets are incomplete: $model_path"
      return 1
    fi

    if [[ ! -f "$model_path" ]]; then
      log "Downloading Piper $lang model from: $model_url"
      model_tmp="${model_path}.tmp"
      if ! download_file "$model_url" "$model_tmp"; then
        rm -f "$model_tmp" || true
        log "Failed to download Piper $lang model."
        return 1
      fi
      mv -f "$model_tmp" "$model_path"
    else
      log "Piper $lang model already present: $model_path"
    fi

    if [[ ! -f "$config_path" ]]; then
      log "Downloading Piper $lang model config from: $config_url"
      config_tmp="${config_path}.tmp"
      if ! download_file "$config_url" "$config_tmp"; then
        rm -f "$config_tmp" || true
        log "Failed to download Piper $lang model config."
        return 1
      fi
      mv -f "$config_tmp" "$config_path"
    else
      log "Piper $lang model config already present: $config_path"
    fi

    log "Piper $lang model installed at: $model_path"
    return 0
  }

  if [[ "$TTS_ENGINE" != "piper" ]]; then
    return 0
  fi

  if [[ -n "$TTS_PIPER_BIN" && -x "$TTS_PIPER_BIN" ]]; then
    :
  elif command -v piper >/dev/null 2>&1; then
    TTS_PIPER_BIN="$(command -v piper)"
  else
    if ! can_perform_privileged_installs; then
      log "ERROR: Piper TTS selected but no Piper binary is available during '$MODE'."
      log "ERROR: Re-run setup-cobien-furniture-environment.sh so Piper is installed before the kiosk service starts."
      return 1
    fi
    log "Piper TTS selected but binary not found. Trying apt install..."
    sudo apt update || true
    sudo apt install -y piper-tts || true

    if command -v piper >/dev/null 2>&1; then
      TTS_PIPER_BIN="$(command -v piper)"
      # infer provider from installation path
      if [[ "$TTS_PIPER_BIN" == */snap/* || "$TTS_PIPER_BIN" == /snap/* ]]; then
        TTS_PIPER_PROVIDER="snap"
      elif [[ "$TTS_PIPER_BIN" == /usr/local/* ]]; then
        TTS_PIPER_PROVIDER="system"
      elif [[ "$TTS_PIPER_BIN" == $HOME/* ]]; then
        TTS_PIPER_PROVIDER="user"
      else
        TTS_PIPER_PROVIDER="system"
      fi
      TTS_PIPER_VERSION="$($TTS_PIPER_BIN --version 2>/dev/null | sed -n '1p' || true)"
      log "Piper installed successfully: $TTS_PIPER_BIN (provider=$TTS_PIPER_PROVIDER)"
    else
      
      install_piper_binary() {
        local arch asset_url asset_tmp extract_dir dest_bin
        arch="$(uname -m)"
        case "$arch" in
          x86_64|amd64) asset="piper_linux_x86_64.tar.gz" ;;
          aarch64|arm64) asset="piper_linux_aarch64.tar.gz" ;;
          *) asset="piper_linux_x86_64.tar.gz" ;;
        esac
        asset_url="https://github.com/rhasspy/piper/releases/download/${TTS_PIPER_RELEASE_TAG_DEFAULT}/${asset}"
        extract_dir="$(mktemp -d)"
        asset_tmp="$extract_dir/$asset"
        log "Attempting to download Piper binary from: $asset_url"
        if ! download_file "$asset_url" "$asset_tmp"; then
          log "Failed to download Piper release asset: $asset_url"
          rm -rf "$extract_dir" || true
          return 1
        fi
        mkdir -p "$HOME/.local/bin"
        if tar -xzf "$asset_tmp" -C "$extract_dir" >/dev/null 2>&1; then
          # find piper executable inside archive
          piper_found="$(find "$extract_dir" -type f -name piper -perm /111 | head -n1 || true)"
          if [[ -n "$piper_found" ]]; then
            dest_bin="$HOME/.local/bin/piper"
            mv -f "$piper_found" "$dest_bin"
            chmod +x "$dest_bin" || true
            rm -rf "$extract_dir" || true
            TTS_PIPER_BIN="$dest_bin"
            TTS_PIPER_PROVIDER="user"
            TTS_PIPER_VERSION="$($TTS_PIPER_BIN --version 2>/dev/null | sed -n '1p' || true)"
            log "Piper binary installed to: $dest_bin"
            return 0
          else
            log "Piper binary not found inside archive"
            rm -rf "$extract_dir" || true
            return 1
          fi
        else
          log "Failed to extract Piper archive: $asset_tmp"
          rm -rf "$extract_dir" || true
          return 1
        fi
      }

      local local_uv=""
      if [[ -n "${UV_BIN:-}" && -x "${UV_BIN:-}" ]]; then
        local_uv="$UV_BIN"
      elif command -v uv >/dev/null 2>&1; then
        local_uv="$(command -v uv)"
      elif [[ -x "$HOME/.local/bin/uv" ]]; then
        local_uv="$HOME/.local/bin/uv"
      fi

      if [[ -n "$local_uv" ]]; then
        log "WARN: Piper not available from apt. Trying UV tool install..."
        "$local_uv" tool install --upgrade piper-tts >/dev/null 2>&1 || true
      fi

      # Install according to requested provider (if set), otherwise prefer snap then system then user
      if [[ -n "$TTS_PIPER_PROVIDER" && "$TTS_PIPER_PROVIDER" != "" ]]; then
        case "$TTS_PIPER_PROVIDER" in
          snap)
            if install_piper_via_snap; then
              log "Piper installed via snap: ${TTS_PIPER_BIN:-/snap/bin/piper}";
            else
              log "Piper snap install failed as requested provider; aborting provider-based install.";
              return 1;
            fi
            ;;
          system)
            if install_piper_system_binary; then
              log "Piper installed system-wide at: ${TTS_PIPER_BIN:-/usr/local/bin/piper}";
            else
              log "Piper system install failed as requested provider; aborting provider-based install.";
              return 1;
            fi
            ;;
          user)
            if install_piper_binary; then
              log "Piper installed to user path: ${TTS_PIPER_BIN:-$HOME/.local/bin/piper}";
            else
              if install_piper_runtime_binary; then
                log "Piper runtime extracted to: ${TTS_PIPER_BIN:-}";
              else
                log "Piper user install failed as requested provider; aborting provider-based install.";
                return 1;
              fi
            fi
            ;;
          skip)
            log "User requested to skip Piper installation.";
            ;;
          *)
            # unknown provider, fall back to default flow
            ;;
        esac
      else
        # Default auto flow: try snap, then system, then user/runtime
        if install_piper_via_snap; then
          log "Piper installed via snap: ${TTS_PIPER_BIN:-/snap/bin/piper}"
        fi
        if [[ -z "$TTS_PIPER_BIN" ]] && install_piper_system_binary; then
          log "Piper installed system-wide at: ${TTS_PIPER_BIN:-/usr/local/bin/piper}"
        fi
      fi

      # Final availability checks: prefer command on PATH, then user-local, then runtime
      if command -v piper >/dev/null 2>&1; then
        TTS_PIPER_BIN="$(command -v piper)"
        # infer provider
        if [[ "$TTS_PIPER_BIN" == */snap/* || "$TTS_PIPER_BIN" == /snap/* ]]; then
          TTS_PIPER_PROVIDER="snap"
        elif [[ "$TTS_PIPER_BIN" == /usr/local/* ]]; then
          TTS_PIPER_PROVIDER="system"
        elif [[ "$TTS_PIPER_BIN" == $HOME/* ]]; then
          TTS_PIPER_PROVIDER="user"
        fi
        TTS_PIPER_VERSION="$($TTS_PIPER_BIN --version 2>/dev/null | sed -n '1p' || true)"
      elif [[ -x "$HOME/.local/bin/piper" ]]; then
        TTS_PIPER_BIN="$HOME/.local/bin/piper"
        TTS_PIPER_PROVIDER="user"
        TTS_PIPER_VERSION="$($TTS_PIPER_BIN --version 2>/dev/null | sed -n '1p' || true)"
      elif install_piper_runtime_binary; then
        :
      else
        log "ERROR: Piper could not be installed automatically."
        return 1
      fi
    fi
  fi

      
  [[ -z "$TTS_PIPER_MODEL_ES_MALE" ]] && TTS_PIPER_MODEL_ES_MALE="$MODELS_DIR/${TTS_PIPER_DEFAULT_MODEL_ES_MALE}.onnx"
  [[ -z "$TTS_PIPER_MODEL_ES_FEMALE" ]] && TTS_PIPER_MODEL_ES_FEMALE="$MODELS_DIR/${TTS_PIPER_DEFAULT_MODEL_ES_FEMALE}.onnx"
  [[ -z "$TTS_PIPER_MODEL_FR_MALE" ]] && TTS_PIPER_MODEL_FR_MALE="$MODELS_DIR/${TTS_PIPER_DEFAULT_MODEL_FR_MALE}.onnx"
  [[ -z "$TTS_PIPER_MODEL_FR_FEMALE" ]] && TTS_PIPER_MODEL_FR_FEMALE="$MODELS_DIR/${TTS_PIPER_DEFAULT_MODEL_FR_FEMALE}.onnx"

  local ok_models="1"
  install_piper_model "es-male" "$TTS_PIPER_MODEL_ES_MALE" "$TTS_PIPER_MODEL_ES_MALE_URL" || ok_models="0"
  install_piper_model "es-female" "$TTS_PIPER_MODEL_ES_FEMALE" "$TTS_PIPER_MODEL_ES_FEMALE_URL" || ok_models="0"
  install_piper_model "fr-male" "$TTS_PIPER_MODEL_FR_MALE" "$TTS_PIPER_MODEL_FR_MALE_URL" || ok_models="0"
  install_piper_model "fr-female" "$TTS_PIPER_MODEL_FR_FEMALE" "$TTS_PIPER_MODEL_FR_FEMALE_URL" || ok_models="0"

  case "${TTS_PIPER_VOICE_ES,,}" in
    female|mujer) TTS_PIPER_VOICE_ES="female"; TTS_PIPER_MODEL_ES="$TTS_PIPER_MODEL_ES_FEMALE"; TTS_PIPER_MODEL_ES_URL="$TTS_PIPER_MODEL_ES_FEMALE_URL" ;;
    *) TTS_PIPER_VOICE_ES="male"; TTS_PIPER_MODEL_ES="$TTS_PIPER_MODEL_ES_MALE"; TTS_PIPER_MODEL_ES_URL="$TTS_PIPER_MODEL_ES_MALE_URL" ;;
  esac

  case "${TTS_PIPER_VOICE_FR,,}" in
    female|mujer) TTS_PIPER_VOICE_FR="female"; TTS_PIPER_MODEL_FR="$TTS_PIPER_MODEL_FR_FEMALE"; TTS_PIPER_MODEL_FR_URL="$TTS_PIPER_MODEL_FR_FEMALE_URL" ;;
    *) TTS_PIPER_VOICE_FR="male"; TTS_PIPER_MODEL_FR="$TTS_PIPER_MODEL_FR_MALE"; TTS_PIPER_MODEL_FR_URL="$TTS_PIPER_MODEL_FR_MALE_URL" ;;
  esac

  if [[ "$ok_models" != "1" ]]; then
    log "ERROR: Piper models are incomplete."
    return 1
  fi

  if [[ -z "$TTS_PIPER_BIN" || ! -x "$TTS_PIPER_BIN" ]]; then
    log "ERROR: Piper binary is not executable after setup: ${TTS_PIPER_BIN:-unset}"
    return 1
  fi

  for required_model in \
    "$TTS_PIPER_MODEL_ES_MALE" \
    "$TTS_PIPER_MODEL_ES_FEMALE" \
    "$TTS_PIPER_MODEL_FR_MALE" \
    "$TTS_PIPER_MODEL_FR_FEMALE"; do
    if [[ -z "$required_model" || ! -f "$required_model" || ! -f "${required_model}.json" ]]; then
      log "ERROR: Piper model assets incomplete: ${required_model:-unset}"
      return 1
    fi
  done
}

ensure_device_identity_config() {
  local unified_config_file
  unified_config_file="$FRONTEND_APP_DIR/config/config.local.json"
  mkdir -p "$(dirname "$unified_config_file")"

  if ! command -v python3 >/dev/null 2>&1; then
    log "Device identity: python3 unavailable, skipping config.local.json generation"
    return
  fi

  COBIEN_APP_LANGUAGE="$APP_LANGUAGE" \
  COBIEN_DEVICE_ID="$DEVICE_ID" \
  COBIEN_VIDEOCALL_ROOM="$VIDEOCALL_ROOM" \
  COBIEN_DEVICE_LOCATION="$DEVICE_LOCATION" \
  COBIEN_WEATHER_CITIES_JSON="$WEATHER_CITIES_JSON" \
  COBIEN_WEATHER_CITY_CATALOG_JSON="$WEATHER_CITY_CATALOG_JSON" \
  COBIEN_WEATHER_PRIMARY_CITY="$WEATHER_PRIMARY_CITY" \
  COBIEN_BUTTON_COLORS_JSON="$BUTTON_COLORS_JSON" \
  COBIEN_RFID_ACTIONS_JSON="$RFID_ACTIONS_JSON" \
  COBIEN_MICROPHONE_DEVICE="$MICROPHONE_DEVICE" \
  COBIEN_AUDIO_OUTPUT_DEVICE="$AUDIO_OUTPUT_DEVICE" \
  COBIEN_JOKE_CATEGORY="$JOKE_CATEGORY" \
  COBIEN_IDLE_TIMEOUT_SEC="$IDLE_TIMEOUT_SEC" \
  COBIEN_NOTIFICATIONS_JSON="$NOTIFICATIONS_JSON" \
  COBIEN_SETTINGS_PIN="$SETTINGS_PIN" \
  COBIEN_RESTART_PIN="$RESTART_PIN" \
  COBIEN_NOTIFY_API_KEY="$NOTIFY_API_KEY" \
  COBIEN_VIDEOCALL_DEVICE_API_KEY="$VIDEOCALL_DEVICE_API_KEY" \
  COBIEN_BACKEND_BASE_URL="$BACKEND_BASE_URL" \
  COBIEN_DEVICE_POLL_URL="$DEVICE_POLL_URL" \
  COBIEN_DEVICE_POLL_INTERVAL_SEC="$DEVICE_POLL_INTERVAL_SEC" \
  COBIEN_DEVICE_HEARTBEAT_URL="$DEVICE_HEARTBEAT_URL" \
  COBIEN_DEVICE_HEARTBEAT_INTERVAL_SEC="$DEVICE_HEARTBEAT_INTERVAL_SEC" \
  COBIEN_PIZARRA_NOTIFY_URL="$PIZARRA_NOTIFY_URL" \
  COBIEN_PIZARRA_API_URL="$PIZARRA_API_URL" \
  COBIEN_PIZARRA_DELETE_URL_TEMPLATE="$PIZARRA_DELETE_URL_TEMPLATE" \
  COBIEN_CONTACTS_API_URL="$CONTACTS_API_URL" \
  COBIEN_ICSO_TELEMETRY_URL="$ICSO_TELEMETRY_URL" \
  COBIEN_ICSO_EVENTS_URL="$ICSO_EVENTS_URL" \
  COBIEN_DEVICE_VIDEOCALL_SESSION_URL="$DEVICE_VIDEOCALL_SESSION_URL" \
  COBIEN_PORTAL_VIDEOCALL_URL="$PORTAL_VIDEOCALL_URL" \
  COBIEN_PORTAL_VIDEOCALL_DEVICE_URL="$PORTAL_VIDEOCALL_DEVICE_URL" \
  COBIEN_PORTAL_CALL_ANSWERED_URL="$PORTAL_CALL_ANSWERED_URL" \
  COBIEN_MQTT_LOCAL_BROKER="$MQTT_LOCAL_BROKER" \
  COBIEN_MQTT_LOCAL_PORT="$MQTT_LOCAL_PORT" \
  COBIEN_HTTP_TIMEOUT="$HTTP_TIMEOUT_SEC" \
  OWM_API_KEY="$OWM_API_KEY" \
  NEWS_API_KEY="$NEWS_API_KEY" \
  MONGO_URI="$MONGO_URI" \
  COBIEN_TTS_ENGINE="$TTS_ENGINE" \
  COBIEN_TTS_RATE="$TTS_RATE" \
  COBIEN_TTS_VOLUME="$TTS_VOLUME" \
  COBIEN_TTS_PIPER_BIN="$TTS_PIPER_BIN" \
  COBIEN_TTS_PIPER_MODEL_ES="$TTS_PIPER_MODEL_ES" \
  COBIEN_TTS_PIPER_MODEL_FR="$TTS_PIPER_MODEL_FR" \
  COBIEN_TTS_PIPER_MODEL_ES_MALE="$TTS_PIPER_MODEL_ES_MALE" \
  COBIEN_TTS_PIPER_MODEL_ES_FEMALE="$TTS_PIPER_MODEL_ES_FEMALE" \
  COBIEN_TTS_PIPER_MODEL_FR_MALE="$TTS_PIPER_MODEL_FR_MALE" \
  COBIEN_TTS_PIPER_MODEL_FR_FEMALE="$TTS_PIPER_MODEL_FR_FEMALE" \
  COBIEN_TTS_PIPER_MODEL_ES_URL="$TTS_PIPER_MODEL_ES_URL" \
  COBIEN_TTS_PIPER_MODEL_FR_URL="$TTS_PIPER_MODEL_FR_URL" \
  COBIEN_TTS_PIPER_MODEL_ES_MALE_URL="$TTS_PIPER_MODEL_ES_MALE_URL" \
  COBIEN_TTS_PIPER_MODEL_ES_FEMALE_URL="$TTS_PIPER_MODEL_ES_FEMALE_URL" \
  COBIEN_TTS_PIPER_MODEL_FR_MALE_URL="$TTS_PIPER_MODEL_FR_MALE_URL" \
  COBIEN_TTS_PIPER_MODEL_FR_FEMALE_URL="$TTS_PIPER_MODEL_FR_FEMALE_URL" \
  COBIEN_TTS_PIPER_VOICE_ES="$TTS_PIPER_VOICE_ES" \
  COBIEN_TTS_PIPER_VOICE_FR="$TTS_PIPER_VOICE_FR" \
  COBIEN_DISABLE_SYSTEM_SLEEP="$DISABLE_SYSTEM_SLEEP" \
  COBIEN_OPENWEATHER_CURRENT_URL="$OPENWEATHER_CURRENT_URL" \
  COBIEN_OPENWEATHER_FORECAST_URL="$OPENWEATHER_FORECAST_URL" \
  COBIEN_NEWS_API_URL="$NEWS_API_URL" \
  COBIEN_OPEN_METEO_URL="$OPEN_METEO_URL" \
  COBIEN_NOMINATIM_SEARCH_URL="$NOMINATIM_SEARCH_URL" \
  python3 - "$unified_config_file" "$FRONTEND_APP_DIR/VERSION" <<'PY'
import json
import os
import sys

config_file, version_file = sys.argv[1:3]
app_dir = os.path.dirname(os.path.dirname(config_file))
if app_dir not in sys.path:
    sys.path.insert(0, app_dir)

from config_runtime import PRESERVED_LOCAL_CONFIG_KEYS

def env(name, default=""):
    return os.getenv(name, default)

def env_int(name, default):
    try:
        return int(float(env(name, str(default))))
    except Exception:
        return default

def env_float(name, default):
    try:
        return float(env(name, str(default)))
    except Exception:
        return default

def env_json(name, default):
    raw = env(name, "")
    if not raw:
        return default
    try:
        value = json.loads(raw)
        return value
    except Exception:
        return default

def load_existing_config(path):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            data = json.load(fh)
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}

def ensure_dict(root, key):
    current = root.get(key)
    if isinstance(current, dict):
        return current
    current = {}
    root[key] = current
    return current

def preserve_existing(target, existing, section, key):
    section_data = existing.get(section)
    if not isinstance(section_data, dict) or key not in section_data:
        return
    ensure_dict(target, section)[key] = section_data[key]

weather_cities = env_json("COBIEN_WEATHER_CITIES_JSON", ["Bilbao", "Toulouse", "Logroño"])
weather_city_catalog = env_json("COBIEN_WEATHER_CITY_CATALOG_JSON", weather_cities)
notifications = env_json("COBIEN_NOTIFICATIONS_JSON", {
    "videollamada": {"group": 1, "intensity": 255, "color": "#00FF00", "mode": "ON", "ringtone": ""},
    "nuevo_evento": {"group": 2, "intensity": 255, "color": "#FF0000", "mode": "ON", "ringtone": ""},
    "nueva_foto": {"group": 3, "intensity": 255, "color": "#0000FF", "mode": "BLINK", "ringtone": ""},
})

software_version = ""
try:
    with open(version_file, "r", encoding="utf-8") as fh:
        software_version = fh.read().strip()
except Exception:
    software_version = ""

existing_data = load_existing_config(config_file)

data = {
    "meta": {
        "schema_version": 1,
        "updated_at": "",
    },
    "settings": {
        "language": env("COBIEN_APP_LANGUAGE", "es"),
        "weather_cities": weather_cities,
        "weather_city_catalog": weather_city_catalog,
        "weather_primary_city": env("COBIEN_WEATHER_PRIMARY_CITY", "Bilbao"),
        "button_colors": env_json("COBIEN_BUTTON_COLORS_JSON", {}),
        "rfid_actions": env_json("COBIEN_RFID_ACTIONS_JSON", {}),
        "microphone_device": env("COBIEN_MICROPHONE_DEVICE", ""),
        "audio_output_device": env("COBIEN_AUDIO_OUTPUT_DEVICE", ""),
        "device_id": env("COBIEN_DEVICE_ID", "CoBien1"),
        "videocall_room": env("COBIEN_VIDEOCALL_ROOM", env("COBIEN_DEVICE_ID", "CoBien1")),
        "device_location": env("COBIEN_DEVICE_LOCATION", "Bilbao"),
        "joke_category": env("COBIEN_JOKE_CATEGORY", "general"),
        "idle_timeout_sec": env_int("COBIEN_IDLE_TIMEOUT_SEC", 60),
    },
    "notifications": notifications,
    "security": {
        "settings_pin": env("COBIEN_SETTINGS_PIN", ""),
        "restart_pin": env("COBIEN_RESTART_PIN", ""),
    },
    "services": {
        "mqtt_local_broker": env("COBIEN_MQTT_LOCAL_BROKER", "localhost"),
        "mqtt_local_port": env_int("COBIEN_MQTT_LOCAL_PORT", 1883),
        "backend_base_url": env("COBIEN_BACKEND_BASE_URL", "https://portal.co-bien.eu"),
        "device_poll_url": env("COBIEN_DEVICE_POLL_URL", "https://portal.co-bien.eu/pizarra/api/device/poll/"),
        "device_poll_interval_sec": env_int("COBIEN_DEVICE_POLL_INTERVAL_SEC", 5),
        "owm_api_key": env("OWM_API_KEY", ""),
        "news_api_key": env("NEWS_API_KEY", ""),
        "mongo_uri": env("MONGO_URI", ""),
        "http_timeout_sec": env_float("COBIEN_HTTP_TIMEOUT", 8.0),
        "tts_engine": env("COBIEN_TTS_ENGINE", "piper"),
        "tts_rate": env_int("COBIEN_TTS_RATE", 155),
        "tts_volume": env_float("COBIEN_TTS_VOLUME", 0.85),
        "tts_piper_bin": env("COBIEN_TTS_PIPER_BIN", ""),
        "tts_piper_model_es": env("COBIEN_TTS_PIPER_MODEL_ES", ""),
        "tts_piper_model_fr": env("COBIEN_TTS_PIPER_MODEL_FR", ""),
        "tts_piper_model_es_male": env("COBIEN_TTS_PIPER_MODEL_ES_MALE", ""),
        "tts_piper_model_es_female": env("COBIEN_TTS_PIPER_MODEL_ES_FEMALE", ""),
        "tts_piper_model_fr_male": env("COBIEN_TTS_PIPER_MODEL_FR_MALE", ""),
        "tts_piper_model_fr_female": env("COBIEN_TTS_PIPER_MODEL_FR_FEMALE", ""),
        "tts_piper_model_es_url": env("COBIEN_TTS_PIPER_MODEL_ES_URL", ""),
        "tts_piper_model_fr_url": env("COBIEN_TTS_PIPER_MODEL_FR_URL", ""),
        "tts_piper_model_es_male_url": env("COBIEN_TTS_PIPER_MODEL_ES_MALE_URL", ""),
        "tts_piper_model_es_female_url": env("COBIEN_TTS_PIPER_MODEL_ES_FEMALE_URL", ""),
        "tts_piper_model_fr_male_url": env("COBIEN_TTS_PIPER_MODEL_FR_MALE_URL", ""),
        "tts_piper_model_fr_female_url": env("COBIEN_TTS_PIPER_MODEL_FR_FEMALE_URL", ""),
        "tts_piper_voice_es": env("COBIEN_TTS_PIPER_VOICE_ES", "male"),
        "tts_piper_voice_fr": env("COBIEN_TTS_PIPER_VOICE_FR", "male"),
        "disable_system_sleep": env("COBIEN_DISABLE_SYSTEM_SLEEP", "0"),
        "notify_api_key": env("COBIEN_NOTIFY_API_KEY", ""),
        "videocall_device_api_key": env("COBIEN_VIDEOCALL_DEVICE_API_KEY", ""),
        "pizarra_notify_url": env("COBIEN_PIZARRA_NOTIFY_URL", "https://portal.co-bien.eu/pizarra/api/notify/"),
        "pizarra_messages_url": env("COBIEN_PIZARRA_API_URL", "https://portal.co-bien.eu/pizarra/api/messages/"),
        "pizarra_delete_url_template": env("COBIEN_PIZARRA_DELETE_URL_TEMPLATE", "https://portal.co-bien.eu/pizarra/api/messages/{post_id}/delete/"),
        "contacts_api_url": env("COBIEN_CONTACTS_API_URL", "https://portal.co-bien.eu/pizarra/api/contacts/"),
        "device_heartbeat_url": env("COBIEN_DEVICE_HEARTBEAT_URL", "https://portal.co-bien.eu/pizarra/api/devices/heartbeat/"),
        "device_heartbeat_interval_sec": env_int("COBIEN_DEVICE_HEARTBEAT_INTERVAL_SEC", 60),
        "icso_telemetry_url": env("COBIEN_ICSO_TELEMETRY_URL", "https://portal.co-bien.eu/pizarra/api/icso/telemetry/"),
        "icso_events_url": env("COBIEN_ICSO_EVENTS_URL", "https://portal.co-bien.eu/pizarra/api/icso/events/"),
        "portal_videocall_url": env("COBIEN_PORTAL_VIDEOCALL_URL", "https://portal.co-bien.eu/videocall/"),
        "portal_videocall_device_url": env("COBIEN_PORTAL_VIDEOCALL_DEVICE_URL", "https://portal.co-bien.eu/videocall/device/"),
        "device_videocall_session_url": env("COBIEN_DEVICE_VIDEOCALL_SESSION_URL", "https://portal.co-bien.eu/api/device-videocall-session/"),
        "portal_call_answered_url": env("COBIEN_PORTAL_CALL_ANSWERED_URL", "https://portal.co-bien.eu/api/call-answered/"),
        "openweather_current_url": env("COBIEN_OPENWEATHER_CURRENT_URL", "https://api.openweathermap.org/data/2.5/weather"),
        "openweather_forecast_url": env("COBIEN_OPENWEATHER_FORECAST_URL", "https://api.openweathermap.org/data/2.5/forecast"),
        "news_api_url": env("COBIEN_NEWS_API_URL", "https://newsapi.org/v2/top-headlines"),
        "open_meteo_url": env("COBIEN_OPEN_METEO_URL", "https://api.open-meteo.com/v1/forecast"),
        "nominatim_search_url": env("COBIEN_NOMINATIM_SEARCH_URL", "https://nominatim.openstreetmap.org/search"),
    },
    "software": {
        "version": software_version,
    },
}

# Keep user-managed values once they have been created locally on the furniture.
# The authoritative policy lives in `app/config_runtime.py`.
for section, keys in PRESERVED_LOCAL_CONFIG_KEYS.items():
    for key in keys:
        preserve_existing(data, existing_data, section, key)

with open(config_file, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=4, ensure_ascii=False)
PY

  log "Device identity synced: language='$APP_LANGUAGE', device_id='$DEVICE_ID', videocall_room='$VIDEOCALL_ROOM', videocall_key='configured', location='$DEVICE_LOCATION', tts_engine='$TTS_ENGINE'"
}

configure_audio_input_defaults() {
  local unified_config_file
  unified_config_file="$FRONTEND_APP_DIR/config/config.local.json"

  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user restart pipewire pipewire-pulse wireplumber >/dev/null 2>&1 || true
    sleep 1
  fi

  if ! command -v pactl >/dev/null 2>&1; then
    log "Audio: pactl not available, skipping audio routing setup"
    return
  fi

  local usb_card hda_source fallback_source
  usb_card="$(pactl list short cards 2>/dev/null | awk 'tolower($0) ~ /usb/ {print $2; exit}')"
  hda_source="$(pactl list short sources 2>/dev/null | awk 'tolower($0) ~ /hda|pci/ && tolower($0) ~ /input/ {print $2; exit}')"
  fallback_source="$(pactl list short sources 2>/dev/null | awk 'tolower($0) ~ /input/ && tolower($0) !~ /usb/ {print $2; exit}')"

  if [[ -n "$usb_card" ]]; then
    if pactl set-card-profile "$usb_card" output:analog-stereo >/dev/null 2>&1; then
      log "Audio: set USB card '$usb_card' profile to output:analog-stereo"
    else
      log "Audio: could not set USB profile on '$usb_card'"
    fi
  else
    log "Audio: no USB card found for profile override"
  fi

  if [[ -n "$hda_source" ]]; then
    if pactl set-default-source "$hda_source" >/dev/null 2>&1; then
      log "Audio: default input source set to '$hda_source'"
    else
      log "Audio: could not set default source '$hda_source'"
    fi
  elif [[ -n "$fallback_source" ]]; then
    if pactl set-default-source "$fallback_source" >/dev/null 2>&1; then
      log "Audio: default input source set to fallback '$fallback_source'"
    else
      log "Audio: could not set fallback source '$fallback_source'"
    fi
  else
    log "Audio: no HDA/PCH input source found"
  fi

  if [[ -f "$unified_config_file" ]] && command -v python3 >/dev/null 2>&1; then
    COBIEN_MICROPHONE_DEVICE="$MICROPHONE_DEVICE" python3 - "$unified_config_file" <<'PY'
import json
import os
import sys
from pathlib import Path

config_file = Path(sys.argv[1])
try:
    data = json.loads(config_file.read_text(encoding="utf-8"))
except Exception:
    data = {}

if not isinstance(data, dict):
    data = {}

settings = data.get("settings")
if not isinstance(settings, dict):
    settings = {}
    data["settings"] = settings

settings["microphone_device"] = os.getenv("COBIEN_MICROPHONE_DEVICE", "")
config_file.write_text(json.dumps(data, indent=4, ensure_ascii=False), encoding="utf-8")
PY
    log "Audio: synced microphone_device in unified config with launcher env"
  fi
}

ensure_mosquitto_running() {
  if pgrep -x mosquitto >/dev/null 2>&1; then
    log "Mosquitto already running (process detected)"
    return
  fi

  if ! command -v mosquitto >/dev/null 2>&1; then
    if ! can_perform_privileged_installs; then
      log "ERROR: Mosquitto binary not found during '$MODE' and privileged installation is not allowed."
      log "ERROR: Re-run setup-cobien-furniture-environment.sh to install the broker before reboot."
      return
    fi
    log "Mosquitto binary not found. Installing it now (sudo may ask for password)..."
    sudo apt update
    sudo apt install -y mosquitto mosquitto-clients
    if ! command -v mosquitto >/dev/null 2>&1; then
      log "Mosquitto installation failed or binary still unavailable."
      return
    fi
  fi

  if command -v systemctl >/dev/null 2>&1; then
    if sudo systemctl list-unit-files --no-legend 2>/dev/null | grep -q "^mosquitto.service"; then
      if sudo systemctl is-active --quiet mosquitto; then
        log "Mosquitto already running (systemd service)"
        return
      fi

      if can_perform_privileged_installs; then
        log "Starting Mosquitto service"
        if sudo systemctl enable --now mosquitto && sudo systemctl is-active --quiet mosquitto; then
          log "Mosquitto started successfully via systemd"
          return
        fi
        log "Could not start Mosquitto via systemd, trying local process fallback"
      else
        log "Mosquitto system service is installed but inactive during '$MODE'; trying local process fallback without sudo"
      fi
    else
      log "mosquitto.service not found, using local process fallback"
    fi
  else
    log "systemctl not available, using local process fallback"
  fi

  local mosq_log_dir="${LOG_DIR:-/tmp}"
  local mosq_log_file="$mosq_log_dir/mosquitto-local.log"
  mkdir -p "$mosq_log_dir"
  nohup mosquitto -p 1883 >"$mosq_log_file" 2>&1 &
  sleep 1

  if pgrep -x mosquitto >/dev/null 2>&1; then
    log "Mosquitto started as local background process (log: $mosq_log_file)"
  else
    log "Failed to start Mosquitto local process. Check log: $mosq_log_file"
  fi
}

install_can_sudoers_rule() {
  local current_user sudoers_file
  current_user="$(id -un)"
  sudoers_file="/etc/sudoers.d/cobien-can"

  log "Installing passwordless CAN setup rule for user: $current_user"
  sudo /bin/sh -c "cat > '$sudoers_file' <<EOF
$current_user ALL=(root) NOPASSWD: /sbin/ip link set can0 down
$current_user ALL=(root) NOPASSWD: /sbin/ip link set can0 up
$current_user ALL=(root) NOPASSWD: /sbin/ip link set can0 type can bitrate *
EOF"
  sudo chmod 440 "$sudoers_file"
  sudo visudo -cf "$sudoers_file" >/dev/null
}

resolve_python_bin() {
  if [[ -n "$PYTHON_BIN" ]]; then
    return
  fi

  if command -v "python${PYTHON_REQUEST}" >/dev/null 2>&1; then
    PYTHON_BIN="python${PYTHON_REQUEST}"
  else
    local fb
    fb="$(python_fallback_bin)"
    PYTHON_BIN="${fb:-python3}"
  fi
}

resolve_uv_bin() {
  if [[ -n "$UV_BIN" ]]; then
    return
  fi

  if command -v uv >/dev/null 2>&1; then
    UV_BIN="uv"
    return
  fi

  if [[ -x "$HOME/.local/bin/uv" ]]; then
    UV_BIN="$HOME/.local/bin/uv"
    return
  fi

  log "Installing uv with the official Astral installer"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh

  if command -v uv >/dev/null 2>&1; then
    UV_BIN="uv"
  elif [[ -x "$HOME/.local/bin/uv" ]]; then
    UV_BIN="$HOME/.local/bin/uv"
  else
    log "Could not locate uv after installation"
    exit 1
  fi
}

prepare_venv() {
  resolve_python_bin
  resolve_uv_bin

  log_phase_banner "Python and virtualenv" "The requested interpreter is always provisioned through uv, and the furniture venv is rebuilt from there."
  animate_status "Ensuring Python ${PYTHON_REQUEST} with uv"
  "$UV_BIN" python install "$PYTHON_REQUEST"

  if [[ "$RECREATE_VENV" == "1" && -d "$VENV_DIR" ]]; then
    log "Removing previous virtual environment: $VENV_DIR"
    rm -rf "$VENV_DIR"
  fi

  animate_status "Preparing the CoBien virtual environment"
  if [[ -d "$VENV_DIR" ]]; then
    "$UV_BIN" venv --clear --python "$PYTHON_REQUEST" "$VENV_DIR"
  else
    "$UV_BIN" venv --python "$PYTHON_REQUEST" "$VENV_DIR"
  fi
  animate_status "Synchronizing Python dependencies with uv"
  "$UV_BIN" sync --python "$PYTHON_REQUEST" --project "$FRONTEND_APP_DIR"
}

write_env_file() {
  shell_quote_env_value() {
    local value="${1-}"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '"%s"' "$value"
  }

  local settings_pin_line=""
  local restart_pin_line=""
  if [[ -n "${COBIEN_SETTINGS_PIN:-}" ]]; then
    settings_pin_line="COBIEN_SETTINGS_PIN=$(shell_quote_env_value "$COBIEN_SETTINGS_PIN")"
  fi
  if [[ -n "${COBIEN_RESTART_PIN:-}" ]]; then
    restart_pin_line="COBIEN_RESTART_PIN=$(shell_quote_env_value "$COBIEN_RESTART_PIN")"
  fi
  # Keep only sensitive values that are not part of the normal launcher flow.
  declare -A existing_env
  if [[ -f "$ENV_FILE" ]]; then
    while IFS='=' read -r k v; do
      [[ -z "$k" || "$k" =~ ^# ]] && continue
      existing_env["$k"]="$v"
    done < <(grep -E '^[^#=]+=' "$ENV_FILE" 2>/dev/null || true)
  fi

  mkdir -p "$(dirname "$ENV_FILE")"
  {
    echo "COBIEN_FRONTEND_REPO=$(shell_quote_env_value "$FRONTEND_REPO")"
    echo "COBIEN_MQTT_REPO=$(shell_quote_env_value "$MQTT_REPO")"
    echo "COBIEN_WORKSPACE_ROOT=$(shell_quote_env_value "$WORKSPACE_ROOT")"
    echo "COBIEN_UPDATE_ENV_FILE=$(shell_quote_env_value "$ENV_FILE")"
    echo "COBIEN_MASTER_ENV_FILE=$(shell_quote_env_value "$MASTER_ENV_FILE")"
    echo "COBIEN_LOG_DIR=$(shell_quote_env_value "$LOG_DIR")"
    echo "COBIEN_MODELS_DIR=$(shell_quote_env_value "$MODELS_DIR")"
    echo "COBIEN_PIPER_RUNTIME_DIR=$(shell_quote_env_value "$PIPER_RUNTIME_DIR")"
    echo "COBIEN_RUNTIME_STATE_DIR=$(shell_quote_env_value "$RUNTIME_STATE_DIR")"
    echo "COBIEN_CACHE_DIR=$(shell_quote_env_value "$CACHE_DIR")"
    echo "COBIEN_UPDATE_REMOTE=$(shell_quote_env_value "$REMOTE_NAME")"
    echo "COBIEN_UPDATE_BRANCH=$(shell_quote_env_value "$BRANCH_NAME")"
    echo "COBIEN_UPDATE_INTERVAL_SEC=$(shell_quote_env_value "$POLL_INTERVAL_SEC")"
    echo "COBIEN_APP_LANGUAGE=$(shell_quote_env_value "$APP_LANGUAGE")"
    echo "COBIEN_DEVICE_ID=$(shell_quote_env_value "$DEVICE_ID")"
    echo "COBIEN_VIDEOCALL_ROOM=$(shell_quote_env_value "$VIDEOCALL_ROOM")"
    echo "COBIEN_NOTIFY_API_KEY=$(shell_quote_env_value "$NOTIFY_API_KEY")"
    echo "COBIEN_VIDEOCALL_DEVICE_API_KEY=$(shell_quote_env_value "$VIDEOCALL_DEVICE_API_KEY")"
    echo "COBIEN_DEVICE_LOCATION=$(shell_quote_env_value "$DEVICE_LOCATION")"
    echo "COBIEN_HARDWARE_MODE=$(shell_quote_env_value "$HARDWARE_MODE")"
    echo "COBIEN_WEATHER_CITIES_JSON=$(shell_quote_env_value "$WEATHER_CITIES_JSON")"
    echo "COBIEN_WEATHER_CITY_CATALOG_JSON=$(shell_quote_env_value "$WEATHER_CITY_CATALOG_JSON")"
    echo "COBIEN_WEATHER_PRIMARY_CITY=$(shell_quote_env_value "$WEATHER_PRIMARY_CITY")"
    echo "COBIEN_BUTTON_COLORS_JSON=$(shell_quote_env_value "$BUTTON_COLORS_JSON")"
    echo "COBIEN_RFID_ACTIONS_JSON=$(shell_quote_env_value "$RFID_ACTIONS_JSON")"
    echo "COBIEN_MICROPHONE_DEVICE=$(shell_quote_env_value "$MICROPHONE_DEVICE")"
    echo "COBIEN_AUDIO_OUTPUT_DEVICE=$(shell_quote_env_value "$AUDIO_OUTPUT_DEVICE")"
    echo "COBIEN_JOKE_CATEGORY=$(shell_quote_env_value "$JOKE_CATEGORY")"
    echo "COBIEN_IDLE_TIMEOUT_SEC=$(shell_quote_env_value "$IDLE_TIMEOUT_SEC")"
    echo "COBIEN_NOTIFICATIONS_JSON=$(shell_quote_env_value "$NOTIFICATIONS_JSON")"
    echo "COBIEN_BACKEND_BASE_URL=$(shell_quote_env_value "$BACKEND_BASE_URL")"
    echo "COBIEN_DEVICE_POLL_URL=$(shell_quote_env_value "$DEVICE_POLL_URL")"
    echo "COBIEN_DEVICE_POLL_INTERVAL_SEC=$(shell_quote_env_value "$DEVICE_POLL_INTERVAL_SEC")"
    echo "COBIEN_DEVICE_HEARTBEAT_URL=$(shell_quote_env_value "$DEVICE_HEARTBEAT_URL")"
    echo "COBIEN_DEVICE_HEARTBEAT_INTERVAL_SEC=$(shell_quote_env_value "$DEVICE_HEARTBEAT_INTERVAL_SEC")"
    echo "OWM_API_KEY=$(shell_quote_env_value "$OWM_API_KEY")"
    echo "NEWS_API_KEY=$(shell_quote_env_value "$NEWS_API_KEY")"
    echo "MONGO_URI=$(shell_quote_env_value "$MONGO_URI")"
    echo "COBIEN_PIZARRA_NOTIFY_URL=$(shell_quote_env_value "$PIZARRA_NOTIFY_URL")"
    echo "COBIEN_PIZARRA_API_URL=$(shell_quote_env_value "$PIZARRA_API_URL")"
    echo "COBIEN_PIZARRA_DELETE_URL_TEMPLATE=$(shell_quote_env_value "$PIZARRA_DELETE_URL_TEMPLATE")"
    echo "COBIEN_CONTACTS_API_URL=$(shell_quote_env_value "$CONTACTS_API_URL")"
    echo "COBIEN_ICSO_TELEMETRY_URL=$(shell_quote_env_value "$ICSO_TELEMETRY_URL")"
    echo "COBIEN_ICSO_EVENTS_URL=$(shell_quote_env_value "$ICSO_EVENTS_URL")"
    echo "COBIEN_DEVICE_VIDEOCALL_SESSION_URL=$(shell_quote_env_value "$DEVICE_VIDEOCALL_SESSION_URL")"
    echo "COBIEN_PORTAL_VIDEOCALL_URL=$(shell_quote_env_value "$PORTAL_VIDEOCALL_URL")"
    echo "COBIEN_PORTAL_VIDEOCALL_DEVICE_URL=$(shell_quote_env_value "$PORTAL_VIDEOCALL_DEVICE_URL")"
    echo "COBIEN_PORTAL_CALL_ANSWERED_URL=$(shell_quote_env_value "$PORTAL_CALL_ANSWERED_URL")"
    echo "COBIEN_MQTT_LOCAL_BROKER=$(shell_quote_env_value "$MQTT_LOCAL_BROKER")"
    echo "COBIEN_MQTT_LOCAL_PORT=$(shell_quote_env_value "$MQTT_LOCAL_PORT")"
    echo "COBIEN_HTTP_TIMEOUT=$(shell_quote_env_value "$HTTP_TIMEOUT_SEC")"
    echo "COBIEN_TTS_ENGINE=$(shell_quote_env_value "$TTS_ENGINE")"
    echo "COBIEN_TTS_RATE=$(shell_quote_env_value "$TTS_RATE")"
    echo "COBIEN_TTS_VOLUME=$(shell_quote_env_value "$TTS_VOLUME")"
    echo "COBIEN_TTS_PIPER_BIN=$(shell_quote_env_value "$TTS_PIPER_BIN")"
    echo "COBIEN_TTS_PIPER_MODEL_ES=$(shell_quote_env_value "$TTS_PIPER_MODEL_ES")"
    echo "COBIEN_TTS_PIPER_MODEL_FR=$(shell_quote_env_value "$TTS_PIPER_MODEL_FR")"
    echo "COBIEN_TTS_PIPER_MODEL_ES_MALE=$(shell_quote_env_value "$TTS_PIPER_MODEL_ES_MALE")"
    echo "COBIEN_TTS_PIPER_MODEL_ES_FEMALE=$(shell_quote_env_value "$TTS_PIPER_MODEL_ES_FEMALE")"
    echo "COBIEN_TTS_PIPER_MODEL_FR_MALE=$(shell_quote_env_value "$TTS_PIPER_MODEL_FR_MALE")"
    echo "COBIEN_TTS_PIPER_MODEL_FR_FEMALE=$(shell_quote_env_value "$TTS_PIPER_MODEL_FR_FEMALE")"
    echo "COBIEN_TTS_PIPER_MODEL_ES_URL=$(shell_quote_env_value "$TTS_PIPER_MODEL_ES_URL")"
    echo "COBIEN_TTS_PIPER_MODEL_FR_URL=$(shell_quote_env_value "$TTS_PIPER_MODEL_FR_URL")"
    echo "COBIEN_TTS_PIPER_MODEL_ES_MALE_URL=$(shell_quote_env_value "$TTS_PIPER_MODEL_ES_MALE_URL")"
    echo "COBIEN_TTS_PIPER_MODEL_ES_FEMALE_URL=$(shell_quote_env_value "$TTS_PIPER_MODEL_ES_FEMALE_URL")"
    echo "COBIEN_TTS_PIPER_MODEL_FR_MALE_URL=$(shell_quote_env_value "$TTS_PIPER_MODEL_FR_MALE_URL")"
    echo "COBIEN_TTS_PIPER_MODEL_FR_FEMALE_URL=$(shell_quote_env_value "$TTS_PIPER_MODEL_FR_FEMALE_URL")"
    echo "COBIEN_TTS_PIPER_VOICE_ES=$(shell_quote_env_value "$TTS_PIPER_VOICE_ES")"
    echo "COBIEN_TTS_PIPER_VOICE_FR=$(shell_quote_env_value "$TTS_PIPER_VOICE_FR")"
    echo "COBIEN_DISABLE_SYSTEM_SLEEP=$(shell_quote_env_value "$DISABLE_SYSTEM_SLEEP")"
    echo "COBIEN_OPENWEATHER_CURRENT_URL=$(shell_quote_env_value "$OPENWEATHER_CURRENT_URL")"
    echo "COBIEN_OPENWEATHER_FORECAST_URL=$(shell_quote_env_value "$OPENWEATHER_FORECAST_URL")"
    echo "COBIEN_NEWS_API_URL=$(shell_quote_env_value "$NEWS_API_URL")"
    echo "COBIEN_OPEN_METEO_URL=$(shell_quote_env_value "$OPEN_METEO_URL")"
    echo "COBIEN_NOMINATIM_SEARCH_URL=$(shell_quote_env_value "$NOMINATIM_SEARCH_URL")"
    echo "COBIEN_INSTALL_SYSTEMD_USER=$(shell_quote_env_value "$INSTALL_SYSTEMD_USER")"
    echo "COBIEN_INSTALL_CRON=$(shell_quote_env_value "$INSTALL_CRON")"
    echo "COBIEN_CRON_SCHEDULE=$(shell_quote_env_value "$CRON_SCHEDULE")"
    echo "COBIEN_ENABLE_WATCH=$(shell_quote_env_value "$ENABLE_WATCH")"
    echo "COBIEN_RECREATE_VENV=$(shell_quote_env_value "$RECREATE_VENV")"
    echo "COBIEN_INSTALL_SYSTEM_DEPS=$(shell_quote_env_value "$INSTALL_SYSTEM_DEPS")"
    echo "COBIEN_TTS_PIPER_PROVIDER=$(shell_quote_env_value "$TTS_PIPER_PROVIDER")"
    echo "COBIEN_TTS_PIPER_VERSION=$(shell_quote_env_value "$TTS_PIPER_VERSION")"
    echo "COBIEN_NON_INTERACTIVE=$(shell_quote_env_value "$NON_INTERACTIVE")"
    echo "COBIEN_AUTO_CONFIRM=$(shell_quote_env_value "$AUTO_CONFIRM")"
    echo "COBIEN_VENV_ACTIVATE=$(shell_quote_env_value "$VENV_DIR/bin/activate")"
    echo "COBIEN_PYTHON_BIN=$(shell_quote_env_value "$PYTHON_BIN")"
    echo "COBIEN_UV_BIN=$(shell_quote_env_value "$UV_BIN")"
    echo "COBIEN_BOOTSTRAP_PYTHON_VERSION=$(shell_quote_env_value "$PYTHON_REQUEST")"
    echo "COBIEN_UV_PYTHON=$(shell_quote_env_value "$PYTHON_REQUEST")"
    echo "COBIEN_FRONTEND_APP_DIR=$(shell_quote_env_value "$FRONTEND_APP_DIR")"
    echo "COBIEN_BRIDGE_DIR=$(shell_quote_env_value "$BRIDGE_DIR")"
    echo "COBIEN_CAN_CONFIG=$(shell_quote_env_value "$CAN_CONFIG")"
    if [[ -n "${existing_env[COBIEN_SETTINGS_PIN]:-}" ]]; then
      echo "COBIEN_SETTINGS_PIN=${existing_env[COBIEN_SETTINGS_PIN]}"
    else
      if [[ -n "$settings_pin_line" ]]; then
        echo "$settings_pin_line"
      fi
    fi
    if [[ -n "${existing_env[COBIEN_RESTART_PIN]:-}" ]]; then
      echo "COBIEN_RESTART_PIN=${existing_env[COBIEN_RESTART_PIN]}"
    else
      if [[ -n "$restart_pin_line" ]]; then
        echo "$restart_pin_line"
      fi
    fi
  } > "$ENV_FILE"
  log "Environment file generated: $ENV_FILE"
}

load_env_file() {
  if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
  fi
  load_master_env_if_present || true
  normalize_device_identity
  set_service_defaults
  reconcile_update_supervision_mode
}

mark_update_applied() {
  mkdir -p "$RUNTIME_STATE_DIR"
  cat > "$UPDATE_MARKER_FILE" <<EOF
{"updated_at":"$(date -Iseconds)","message":"The system has been updated."}
EOF
  log "Update marker written: $UPDATE_MARKER_FILE"
}

is_existing_installation_ready() {
  [[ -f "$ENV_FILE" && -d "$VENV_DIR" ]]
}

setup_environment() {
  log_phase_banner "Full setup" "Preparing repositories, uv, Python, voice runtime and the generated local config."
  check_paths
  install_system_deps_fn
  install_can_sudoers_rule
  animate_status "Switching both repositories to the requested branch"
  checkout_branch "$FRONTEND_REPO"
  checkout_branch "$MQTT_REPO"
  prepare_venv
  # Ensure Piper runtime and models are installed so ENV_FILE contains correct paths
  animate_status "Configuring the Piper runtime and voice assets"
  configure_tts_runtime
  animate_status "Writing runtime env and config.local.json"
  write_env_file
}

check_repo() {
  local repo="$1"
  [[ -d "$repo/.git" ]]
}

repo_updates_launcher() {
  local repo="$1"
  local from_sha="$2"
  local to_sha="$3"
  [[ "$repo" == "$LAUNCHER_ROOT" ]] || return 1
  git -C "$repo" diff --name-only "$from_sha" "$to_sha" | grep -Fxq "cobien-launcher.sh"
}

handoff_to_updated_launcher() {
  local next_mode="$1"

  log "Launcher script changed; re-executing updated launcher in current terminal"
  release_single_instance_lock
  exec /bin/bash "$SELF_SCRIPT" \
    --non-interactive \
    --yes \
    --relaunch-after-update \
    --mode "$next_mode" \
    --workspace "$WORKSPACE_ROOT" \
    --frontend-name "$FRONTEND_REPO_NAME" \
    --mqtt-name "$MQTT_REPO_NAME" \
    --app-language "$APP_LANGUAGE" \
    --device-id "$DEVICE_ID" \
    --videocall-room "$VIDEOCALL_ROOM" \
    --device-location "$DEVICE_LOCATION" \
    --hardware-mode "$HARDWARE_MODE" \
    --tts-engine "$TTS_ENGINE" \
    --tts-piper-bin "$TTS_PIPER_BIN" \
    --tts-piper-model-es "$TTS_PIPER_MODEL_ES" \
    --tts-piper-model-fr "$TTS_PIPER_MODEL_FR" \
    --tts-piper-model-es-male "$TTS_PIPER_MODEL_ES_MALE" \
    --tts-piper-model-es-female "$TTS_PIPER_MODEL_ES_FEMALE" \
    --tts-piper-model-fr-male "$TTS_PIPER_MODEL_FR_MALE" \
    --tts-piper-model-fr-female "$TTS_PIPER_MODEL_FR_FEMALE" \
    --tts-piper-model-es-url "$TTS_PIPER_MODEL_ES_URL" \
    --tts-piper-model-fr-url "$TTS_PIPER_MODEL_FR_URL" \
    --tts-piper-model-es-male-url "$TTS_PIPER_MODEL_ES_MALE_URL" \
    --tts-piper-model-es-female-url "$TTS_PIPER_MODEL_ES_FEMALE_URL" \
    --tts-piper-model-fr-male-url "$TTS_PIPER_MODEL_FR_MALE_URL" \
    --tts-piper-model-fr-female-url "$TTS_PIPER_MODEL_FR_FEMALE_URL" \
    --tts-piper-voice-es "$TTS_PIPER_VOICE_ES" \
    --tts-piper-voice-fr "$TTS_PIPER_VOICE_FR"
}

update_repo_if_needed() {
  local repo="$1"
  local handoff_mode="${2:-launch}"

  if ! check_repo "$repo"; then
    log "Invalid repository: $repo"
    return 2
  fi

  local current_branch local_sha remote_sha
  current_branch="$(git -C "$repo" branch --show-current)"
  if [[ "$current_branch" != "$BRANCH_NAME" ]]; then
    log "Skipping $repo: current branch '$current_branch', expected '$BRANCH_NAME'"
    return 2
  fi

  log "Checking changes in $repo"
  git -C "$repo" fetch "$REMOTE_NAME" "$BRANCH_NAME" --quiet
  local_sha="$(git -C "$repo" rev-parse HEAD)"
  remote_sha="$(git -C "$repo" rev-parse FETCH_HEAD)"

  if [[ "$local_sha" == "$remote_sha" ]]; then
    log "No changes in $repo"
    return 1
  fi

  local launcher_changed="0"
  if repo_updates_launcher "$repo" "$local_sha" "$remote_sha"; then
    launcher_changed="1"
  fi

  log "Updating $repo"
  git -C "$repo" pull --ff-only "$REMOTE_NAME" "$BRANCH_NAME"

  if [[ "$launcher_changed" == "1" ]]; then
    mark_update_applied
    handoff_to_updated_launcher "$handoff_mode"
  fi

  return 0
}

dedupe_existing_update_cron_entries() {
  local current_cron filtered seen_update
  current_cron="$(crontab -l 2>/dev/null || true)"
  seen_update="0"

  filtered="$(
    while IFS= read -r line; do
      if [[ "$line" == *"$SELF_SCRIPT --mode update-once"* ]]; then
        if [[ "$seen_update" == "0" ]]; then
          seen_update="1"
          printf "%s\n" "$line"
        fi
      else
        printf "%s\n" "$line"
      fi
    done <<<"$current_cron"
  )"

  if [[ "$filtered" != "$current_cron" ]]; then
    printf "%s\n" "$filtered" | sed '/^[[:space:]]*$/d' | crontab -
    log "Deduplicated existing update cron entries."
  fi
}

restart_software() {
  local relaunch_after_update="${1:-0}"
  log "Relaunching furniture software"
  if [[ "$relaunch_after_update" == "1" ]]; then
    if [[ "$INSTALL_SYSTEMD_USER" == "1" ]] || has_systemd_user_launcher_service; then
      log "Update-triggered relaunch detected under systemd supervision."
      log "Delegating restart to cobien-launcher.service to avoid overlapping runtimes."
      release_single_instance_lock
      restart_systemd_user_launcher_service
      exit 0
    fi
    log "Update-triggered relaunch will use clean-launch mode."
    release_single_instance_lock
    exec /bin/bash "$SELF_SCRIPT" \
      --non-interactive \
      --yes \
      --force-restart \
      --relaunch-after-update \
      --mode clean-launch \
      --workspace "$WORKSPACE_ROOT" \
      --frontend-name "$FRONTEND_REPO_NAME" \
      --mqtt-name "$MQTT_REPO_NAME" \
      --app-language "$APP_LANGUAGE" \
      --device-id "$DEVICE_ID" \
      --videocall-room "$VIDEOCALL_ROOM" \
      --device-location "$DEVICE_LOCATION" \
      --hardware-mode "$HARDWARE_MODE" \
      --tts-engine "$TTS_ENGINE" \
      --tts-piper-bin "$TTS_PIPER_BIN" \
      --tts-piper-model-es "$TTS_PIPER_MODEL_ES" \
      --tts-piper-model-fr "$TTS_PIPER_MODEL_FR" \
      --tts-piper-model-es-male "$TTS_PIPER_MODEL_ES_MALE" \
      --tts-piper-model-es-female "$TTS_PIPER_MODEL_ES_FEMALE" \
      --tts-piper-model-fr-male "$TTS_PIPER_MODEL_FR_MALE" \
      --tts-piper-model-fr-female "$TTS_PIPER_MODEL_FR_FEMALE" \
      --tts-piper-model-es-url "$TTS_PIPER_MODEL_ES_URL" \
      --tts-piper-model-fr-url "$TTS_PIPER_MODEL_FR_URL" \
      --tts-piper-model-es-male-url "$TTS_PIPER_MODEL_ES_MALE_URL" \
      --tts-piper-model-es-female-url "$TTS_PIPER_MODEL_ES_FEMALE_URL" \
      --tts-piper-model-fr-male-url "$TTS_PIPER_MODEL_FR_MALE_URL" \
      --tts-piper-model-fr-female-url "$TTS_PIPER_MODEL_FR_FEMALE_URL" \
      --tts-piper-voice-es "$TTS_PIPER_VOICE_ES" \
      --tts-piper-voice-fr "$TTS_PIPER_VOICE_FR" \
      --branch "$BRANCH_NAME"
  fi
  launch_runtime 0
}

run_update_once() {
  local handoff_mode="${1:-launch}"
  local updated=0
  local manual_reload_requested="0"

  check_paths
  load_env_file
  if is_manual_update_reload_requested; then
    manual_reload_requested="1"
    log "Manual update requested from furniture administration; runtime will be relaunched even if repositories are already up to date."
  fi
  log_phase_banner "Repository update" "Refreshing cobien_FrontEnd and cobien_MQTT_Dictionnary before continuing with the runtime."
  log "Preparing update handoff: ensuring only one launcher/runtime instance remains before updating."

  if ! is_running_inside_systemd_user_service && has_active_systemd_user_launcher_service; then
    stop_systemd_user_launcher_supervision || true
  fi
  stop_all_other_launcher_processes || true
  wait_for_no_other_launcher_processes 10 || true
  stop_runtime_processes
  wait_for_runtime_shutdown 20 || true

  if update_repo_if_needed "$FRONTEND_REPO" "$handoff_mode"; then
    updated=1
  fi

  if update_repo_if_needed "$MQTT_REPO" "$handoff_mode"; then
    updated=1
  fi

  if [[ "$updated" -eq 1 ]]; then
    mark_update_applied
    clear_manual_update_reload_request
    restart_software 1
  elif [[ "$manual_reload_requested" == "1" ]]; then
    log "No repository changes found, but manual update requested a full runtime reload."
    clear_manual_update_reload_request
    restart_software 1
  else
    log "No changes to deploy"
  fi
}

preflight_update_before_launch() {
  local handoff_mode="${1:-launch}"
  log "Boot/start preflight: checking frontend and MQTT repositories before launching the furniture runtime."
  run_update_once "$handoff_mode"
}

run_watch_loop() {
  local elapsed
  check_paths
  load_env_file
  normalize_device_identity
  log "Watch mode enabled; interval ${POLL_INTERVAL_SEC}s"
  while true; do
    run_update_once watch
    elapsed=0
    while [[ "$elapsed" -lt "$POLL_INTERVAL_SEC" ]]; do
      ensure_runtime_supervision
      sleep 2
      elapsed=$((elapsed + 2))
    done
  done
}

install_cron_job() {
  local cron_line current_cron cron_log_file
  cron_log_file="${HOME}/cobien-update.log"
  cron_line="$CRON_SCHEDULE /bin/bash \"$SELF_SCRIPT\" --mode update-once --workspace \"$WORKSPACE_ROOT\" --frontend-name \"$FRONTEND_REPO_NAME\" --mqtt-name \"$MQTT_REPO_NAME\" >> \"$cron_log_file\" 2>&1"
  current_cron="$(crontab -l 2>/dev/null || true)"
  current_cron="$(printf '%s\n' "$current_cron" | awk -v script="$SELF_SCRIPT" 'index($0, script " --mode update-once")==0')"

  {
    printf "%s\n" "$current_cron" | sed '/^[[:space:]]*$/d'
    printf "%s\n" "$cron_line"
  } | crontab -

  log "Cron job installed (deduplicated):"
  log "  $cron_line"
}

install_systemd_user_services() {
  log "Installing/updating systemd user services..."
  local systemd_src_dir="$LAUNCHER_ROOT/systemd"
  local systemd_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
  local systemd_override_dir="$systemd_user_dir/cobien-launcher.service.d"
  local autostart_dir="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
  local autostart_file="$autostart_dir/cobien-import-session-env.desktop"
  local openbox_dir="${XDG_CONFIG_HOME:-$HOME/.config}/openbox"
  local openbox_autostart_file="$openbox_dir/autostart"
  local openbox_sentinel="# CoBien session env import"
  local timers_wants_dir="$systemd_user_dir/timers.target.wants"
  local graphical_wants_dir="$systemd_user_dir/graphical-session.target.wants"

  mkdir -p "$systemd_user_dir" "$autostart_dir" "$openbox_dir" "$timers_wants_dir" "$graphical_wants_dir"

  if command -v loginctl >/dev/null 2>&1; then
    loginctl enable-linger "$USER" >/dev/null 2>&1 || true
    log "Enabled linger for user: $USER"
  fi

  install -m 0644 "$systemd_src_dir/cobien-launcher.service" "$systemd_user_dir/cobien-launcher.service"
  install -m 0644 "$systemd_src_dir/cobien-update.service" "$systemd_user_dir/cobien-update.service"
  install -m 0644 "$systemd_src_dir/cobien-update.timer" "$systemd_user_dir/cobien-update.timer"
  rm -rf "$systemd_override_dir"

  cat > "$autostart_file" <<EOF
[Desktop Entry]
Type=Application
Name=CoBien Session Env Import
Comment=Import GNOME/XFCE/Openbox graphical environment into systemd user services
Exec=/bin/bash $LAUNCHER_ROOT/import-systemd-user-env.sh
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=2
X-XFCE-Autostart-enabled=true
X-MATE-Autostart-enabled=true
NoDisplay=true
Terminal=false
EOF

  if [[ ! -f "$openbox_autostart_file" ]]; then
    cat > "$openbox_autostart_file" <<EOF
$openbox_sentinel
/bin/bash $LAUNCHER_ROOT/import-systemd-user-env.sh &
EOF
  elif ! grep -Fq "$openbox_sentinel" "$openbox_autostart_file"; then
    printf '\n%s\n%s\n' "$openbox_sentinel" "/bin/bash $LAUNCHER_ROOT/import-systemd-user-env.sh &" >> "$openbox_autostart_file"
  fi

  if crontab -l >/dev/null 2>&1; then
    crontab -l | grep -v 'cobien-launcher.sh --mode update-once' | crontab - || true
  fi

  ln -sfn ../cobien-launcher.service "$graphical_wants_dir/cobien-launcher.service"
  ln -sfn ../cobien-update.timer "$timers_wants_dir/cobien-update.timer"

  systemctl --user daemon-reload >/dev/null 2>&1 || true
  systemctl --user enable --now cobien-launcher.service >/dev/null 2>&1 || true
  systemctl --user enable --now cobien-update.timer >/dev/null 2>&1 || true
  systemctl --user restart cobien-launcher.service >/dev/null 2>&1 || true
}

has_systemd_user_launcher_service() {
  local service_file="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/cobien-launcher.service"
  [[ -f "$service_file" ]]
}

reconcile_update_supervision_mode() {
  if [[ "$INSTALL_SYSTEMD_USER" == "1" ]] || has_systemd_user_launcher_service; then
    if [[ "$ENABLE_WATCH" == "1" ]]; then
      log "UPDATE: systemd user supervision detected; disabling internal watch loop to keep a single update system."
    fi
    ENABLE_WATCH="0"
  fi
}

restart_systemd_user_launcher_service() {
  if ! command -v systemctl >/dev/null 2>&1; then
    return 1
  fi

  log "Restarting systemd user launcher service so the previous runtime is stopped before relaunch."
  systemctl --user daemon-reload >/dev/null 2>&1 || true
  systemctl --user restart cobien-launcher.service
}

verify_systemd_user_services() {
  if ! command -v systemctl >/dev/null 2>&1; then
    log "Verification skipped: systemctl not available"
    return 1
  fi

  log "Running systemd user verification..."
  systemctl --user daemon-reload
  systemctl --user enable --now cobien-launcher.service cobien-update.timer
  systemctl --user restart cobien-launcher.service

  if systemctl --user is-active --quiet cobien-launcher.service; then
    log "Verification OK: cobien-launcher.service is active"
  else
    log "Verification FAILED: cobien-launcher.service is not active"
    return 1
  fi

  if systemctl --user is-enabled --quiet cobien-update.timer; then
    log "Verification OK: cobien-update.timer is enabled"
  else
    log "Verification FAILED: cobien-update.timer is not enabled"
    return 1
  fi
}

print_dry_run() {
  set_phase "dry-run"
  check_paths
  load_env_file
  normalize_device_identity
  validate_runtime_file_dependencies
  log "MODE=$MODE"
  log "WORKSPACE_ROOT=$WORKSPACE_ROOT"
  log "FRONTEND_REPO=$FRONTEND_REPO"
  log "MQTT_REPO=$MQTT_REPO"
  log "FRONTEND_APP_DIR=$FRONTEND_APP_DIR"
  log "BRANCH_NAME=$BRANCH_NAME"
  log "REMOTE_NAME=$REMOTE_NAME"
  log "POLL_INTERVAL_SEC=$POLL_INTERVAL_SEC"
  log "APP_LANGUAGE=$APP_LANGUAGE"
  log "DEVICE_ID=$DEVICE_ID"
  log "VIDEOCALL_ROOM=$VIDEOCALL_ROOM"
  if [[ -n "$VIDEOCALL_DEVICE_API_KEY" ]]; then
    log "VIDEOCALL_DEVICE_API_KEY=configured"
  else
    log "VIDEOCALL_DEVICE_API_KEY=missing"
  fi
  log "DEVICE_LOCATION=$DEVICE_LOCATION"
  log "HARDWARE_MODE=$HARDWARE_MODE"
  log "TTS_ENGINE=$TTS_ENGINE"
  log "TTS_PIPER_BIN=${TTS_PIPER_BIN:-auto}"
  log "TTS_PIPER_MODEL_ES=${TTS_PIPER_MODEL_ES:-unset}"
  log "TTS_PIPER_MODEL_FR=${TTS_PIPER_MODEL_FR:-unset}"
  log "TTS_PIPER_MODEL_ES_URL=${TTS_PIPER_MODEL_ES_URL:-default}"
  log "TTS_PIPER_MODEL_FR_URL=${TTS_PIPER_MODEL_FR_URL:-default}"
  log "TTS_PIPER_VOICE_ES=${TTS_PIPER_VOICE_ES:-male}"
  log "TTS_PIPER_VOICE_FR=${TTS_PIPER_VOICE_FR:-male}"
  log "ENV_FILE=$ENV_FILE"
  log "MASTER_ENV_FILE=$MASTER_ENV_FILE"
  log "UV_BIN=${UV_BIN:-unresolved}"
  log "PYTHON_REQUEST=$PYTHON_REQUEST"
  print_runtime_summary
}

print_diagnostics() {
  # Non-destructive diagnostics to help debug Piper/install/runtime issues
  set_phase "diagnostics"
  set +e
  check_paths || true
  load_env_file || true
  normalize_device_identity || true
  validate_runtime_file_dependencies || true

  log_section "Diagnostics"
  log "User: $(id -un 2>/dev/null || true) (uid=$(id -u 2>/dev/null || true))"
  log "Shell: ${SHELL:-unknown}"
  log "PATH: ${PATH:-}" 
  log "Which piper: $(command -v piper 2>/dev/null || echo 'not found')"
  log "TTS_PIPER_BIN: ${TTS_PIPER_BIN:-unset}"
  log "ENV_FILE: $ENV_FILE"
  log "MASTER_ENV_FILE: $MASTER_ENV_FILE"
  log "FRONTEND_REPO: ${FRONTEND_REPO:-unresolved}"
  log "MQTT_REPO: ${MQTT_REPO:-unresolved}"

  log "--- critical file dependency status ---"
  print_file_status "Deployment env" "${MASTER_ENV_FILE:-unresolved}"
  print_file_status "Runtime env" "${ENV_FILE:-unresolved}"
  print_file_status "Config dir" "$GLOBAL_CONFIG_DIR" dir
  print_file_status "State dir" "$GLOBAL_STATE_DIR" dir
  print_file_status "Cache dir" "$GLOBAL_CACHE_DIR" dir
  print_file_status "Data dir" "$GLOBAL_DATA_DIR" dir
  print_file_status "Models dir" "$MODELS_DIR" dir
  print_file_status "Piper runtime dir" "$PIPER_RUNTIME_DIR" dir
  print_file_status "Unified config" "$FRONTEND_APP_DIR/config/config.local.json"
  print_file_status "Default config" "$FRONTEND_APP_DIR/config/config.default.json"
  print_file_status "Launcher contract" "$FRONTEND_APP_DIR/config_runtime.py"
  print_file_status "Main app" "$FRONTEND_APP_DIR/mainApp.py"
  print_file_status "Pyproject" "$FRONTEND_APP_DIR/pyproject.toml"
  print_file_status "Bridge dir" "$BRIDGE_DIR" dir
  print_file_status "CAN config" "$CAN_CONFIG"
  print_file_status "Session env helper" "$LAUNCHER_ROOT/import-systemd-user-env.sh"

  if [[ -f "$ENV_FILE" ]]; then
    log "--- ENV_FILE contents ---"
    sed -n '1,200p' "$ENV_FILE" 2>/dev/null || true
  else
    log "ENV_FILE not found: $ENV_FILE"
  fi

  local cfg="$FRONTEND_APP_DIR/config/config.local.json"
  log "Unified config: $cfg"
  if [[ -f "$cfg" ]]; then
    log "--- config.local.json (first 200 lines) ---"
    sed -n '1,200p' "$cfg" 2>/dev/null || true
  else
    log "config.local.json missing"
  fi

  log "Piper models dir: $MODELS_DIR"
  if [[ -d "$MODELS_DIR" ]]; then
    ls -la "$MODELS_DIR" 2>/dev/null || true
  else
    log "Piper models directory not present"
  fi

  log "Checking common piper locations"
  if [[ -x "$HOME/.local/bin/piper" ]]; then
    log "Found user piper at $HOME/.local/bin/piper (version)"
    "$HOME/.local/bin/piper" --version 2>&1 | sed -n '1,5p' || true
  fi
  if command -v piper >/dev/null 2>&1; then
    log "System piper: $(command -v piper)"
    piper --version 2>&1 | sed -n '1,5p' || true
  else
    log "piper not available on PATH"
  fi

  log "systemd user service status (if available)"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user status cobien-launcher.service --no-pager 2>&1 || true
    systemctl --user status cobien-update.timer --no-pager 2>&1 || true
  else
    log "systemctl not available"
  fi

  log "crontab (current user):"
  crontab -l 2>/dev/null || log "no crontab for user"

  log "Last run config file: $LAST_RUN_CONFIG_FILE"
  if [[ -f "$LAST_RUN_CONFIG_FILE" ]]; then
    sed -n '1,200p' "$LAST_RUN_CONFIG_FILE" 2>/dev/null || true
  fi

  log_section "Diagnostics end"
  set -e
}

run_full_flow() {
  local reuse_existing_installation="0"
  local use_last_config="0"
  local first_run_without_systemd="0"
  local launcher_action="1"
  local master_env_loaded="0"
  local master_env_complete="0"
  local force_full_install_from_master_env="0"
  local use_master_env_config="0"
  local offer_unattended_defaults="0"
  if [[ "$NON_INTERACTIVE" != "1" ]]; then
    log_section "CoBien Ubuntu Setup Assistant"
    print_intro
    [[ "$ARGS_PROVIDED" == "0" ]] && offer_unattended_defaults="1"
  fi

  if load_master_env_if_present; then
    master_env_loaded="1"
    if master_env_is_complete; then
      master_env_complete="1"
      log "Deployment env is complete. The launcher will use it as the source of truth."
      log "A full deployment will be executed from the deployment env, including dependencies, environment, models, config and runtime."
      print_key_value "Deployment env" "$MASTER_ENV_FILE"
      if [[ "$NON_INTERACTIVE" == "1" ]]; then
        use_master_env_config="1"
        force_full_install_from_master_env="1"
        AUTO_CONFIRM="1"
      elif ask_yes_no "A complete deployment env was found. Do you want to use this configuration for a full installation and launch" "y"; then
        use_master_env_config="1"
        force_full_install_from_master_env="1"
        NON_INTERACTIVE="1"
        AUTO_CONFIRM="1"
      else
        log "The assistant will ignore the detected deployment env and continue with manual review."
      fi
    else
      log "Deployment env found but incomplete. The assistant will only ask for the missing values."
    fi
  fi

  if [[ "$NON_INTERACTIVE" != "1" && "$use_master_env_config" != "1" && "$offer_unattended_defaults" == "1" ]]; then
    if ask_yes_no "Do you want to run in unattended mode using the detected/default configuration" "n"; then
      NON_INTERACTIVE="1"
      AUTO_CONFIRM="1"
    fi
  fi

  if [[ "$use_master_env_config" == "1" ]]; then
    run_full_install_plan 0
    return
  fi

  if [[ "$NON_INTERACTIVE" != "1" ]]; then
    echo
    launcher_action="$(
      ask_menu_choice \
        "Choose the deployment flow you want to run:" \
        "1" \
        "1. Guided full deployment: validate config, prepare runtime, install models, and launch." \
        "2. Normal launch: start the furniture runtime using the current installation." \
        "3. Clean relaunch: stop old runtime state and launch from a clean slate." \
        "4. Setup only: install dependencies, Python/uv, .venv and models, but do not launch." \
        "5. Update only: fetch latest code and redeploy if changes exist."
    )"

    case "$launcher_action" in
      2)
        MODE="launch"
        return
        ;;
      3)
        MODE="clean-launch"
        FORCE_RESTART="1"
        return
        ;;
      4)
        MODE="setup"
        return
        ;;
      5)
        MODE="update-once"
        return
        ;;
    esac
  fi

  if [[ "$master_env_complete" != "1" && "$NON_INTERACTIVE" != "1" ]] && load_last_run_config; then
    normalize_device_identity
    print_last_run_config_summary
    if ask_yes_no "Do you want to reuse this previous configuration and run a full reinstall" "y"; then
      use_last_config="1"
      INSTALL_SYSTEM_DEPS="1"
      RECREATE_VENV="1"
      reuse_existing_installation="0"
    fi
  fi

  if [[ "$use_last_config" != "1" && "$use_master_env_config" != "1" ]]; then
    if [[ "$master_env_complete" != "1" ]]; then
      print_question_group "Project Layout"
      WORKSPACE_ROOT="$(ask "Workspace directory containing both projects" "$WORKSPACE_ROOT")"
      FRONTEND_REPO_NAME="$(ask "Frontend repository directory name" "$FRONTEND_REPO_NAME")"
      MQTT_REPO_NAME="$(ask "MQTT/CAN repository directory name" "$MQTT_REPO_NAME")"
    fi
    normalize_device_identity
    if [[ "$master_env_complete" != "1" || "$master_env_loaded" == "0" ]]; then
      print_question_group "Furniture Identity"
      APP_LANGUAGE="$(ask "Application language (es/fr)" "$APP_LANGUAGE")"
      normalize_device_identity
      DEVICE_ID="$(ask "Device ID (unique furniture identifier)" "$DEVICE_ID")"
      VIDEOCALL_ROOM="$(ask "Videocall room for this furniture" "${VIDEOCALL_ROOM:-$DEVICE_ID}")"
    fi
    normalize_device_identity
    print_question_group "Backend Connectivity"
    NOTIFY_API_KEY="$(ask_secret_required "Notify API key used for polling, sync and secure backend calls" "$NOTIFY_API_KEY")"
    VIDEOCALL_DEVICE_API_KEY="$(ask_secret_required "Videocall device API key for $DEVICE_ID" "$VIDEOCALL_DEVICE_API_KEY")"
    BACKEND_BASE_URL="$(ask "Backend base URL (portal root)" "$BACKEND_BASE_URL")"
    set_service_defaults
    DEVICE_POLL_URL="$(ask "Device poll URL (backend queue endpoint)" "$DEVICE_POLL_URL")"
    DEVICE_HEARTBEAT_URL="$(ask "Device heartbeat URL" "$DEVICE_HEARTBEAT_URL")"
    CONTACTS_API_URL="$(ask "Contacts API URL" "$CONTACTS_API_URL")"
    PIZARRA_NOTIFY_URL="$(ask "Pizarra notify URL" "$PIZARRA_NOTIFY_URL")"
    PIZARRA_API_URL="$(ask "Pizarra messages URL" "$PIZARRA_API_URL")"
    DEVICE_VIDEOCALL_SESSION_URL="$(ask "Videocall session URL" "$DEVICE_VIDEOCALL_SESSION_URL")"
    PORTAL_VIDEOCALL_DEVICE_URL="$(ask "Portal videocall device URL" "$PORTAL_VIDEOCALL_DEVICE_URL")"
    PORTAL_CALL_ANSWERED_URL="$(ask "Portal call answered URL" "$PORTAL_CALL_ANSWERED_URL")"
    ICSO_TELEMETRY_URL="$(ask "ICSO telemetry URL" "$ICSO_TELEMETRY_URL")"
    ICSO_EVENTS_URL="$(ask "ICSO events URL" "$ICSO_EVENTS_URL")"
    print_question_group "Local Runtime"
    DEVICE_LOCATION="$(ask "Furniture location or city" "$DEVICE_LOCATION")"
    HARDWARE_MODE="$(ask "Hardware mode (auto/real/mock)" "$HARDWARE_MODE")"
    SETTINGS_PIN="$(ask "Admin PIN (optional)" "$SETTINGS_PIN")"
    TTS_ENGINE="$(ask "TTS engine (pyttsx3/piper)" "$TTS_ENGINE")"
    if [[ "$TTS_ENGINE" == "piper" ]]; then
      TTS_PIPER_BIN="$(ask "Piper binary path (empty=auto detect)" "$TTS_PIPER_BIN")"
      # If user provided an explicit path, treat provider as 'user'
      if [[ -n "$TTS_PIPER_BIN" ]]; then
        TTS_PIPER_PROVIDER="user"
      else
        if [[ "$NON_INTERACTIVE" == "1" ]]; then
          # prefer snap in non-interactive mode
          TTS_PIPER_PROVIDER="snap"
        else
          echo
          local provider_choice
          provider_choice=$(ask_menu_choice \
            "How should Piper be installed if it is missing?" \
            "1" \
            "1. snap (recommended, persistent, easy to maintain)" \
            "2. system (install to /usr/local, requires sudo)" \
            "3. user (install to ~/.local/bin for this account)" \
            "4. skip (leave Piper unmanaged by the launcher)"
          )
          case "$provider_choice" in
            1) TTS_PIPER_PROVIDER="snap" ;;
            2) TTS_PIPER_PROVIDER="system" ;;
            3) TTS_PIPER_PROVIDER="user" ;;
            4) TTS_PIPER_PROVIDER="skip" ;;
            *) TTS_PIPER_PROVIDER="snap" ;;
          esac
        fi
      fi
      TTS_PIPER_VOICE_ES="$(ask "Piper Spanish voice (male/female)" "$TTS_PIPER_VOICE_ES")"
      TTS_PIPER_VOICE_FR="$(ask "Piper French voice (male/female)" "$TTS_PIPER_VOICE_FR")"
    fi
  fi
  set_service_defaults
  validate_current_runtime_config
  resolve_paths

  if ! has_systemd_user_launcher_service; then
    first_run_without_systemd="1"
    INSTALL_SYSTEMD_USER="1"
    log "First run detected: systemd user service missing, auto-install enabled."
  fi

  if [[ "$use_last_config" != "1" ]] && is_existing_installation_ready && [[ "$RECREATE_VENV" != "1" ]]; then
    reuse_existing_installation="1"
    INSTALL_SYSTEM_DEPS="0"
  fi

  if detect_requested_python; then
    echo "Python ${PYTHON_REQUEST} detected on the host: $(command -v "python${PYTHON_REQUEST}")"
  else
    echo "Python ${PYTHON_REQUEST} is not currently installed on the host."
    echo "The launcher will provision it inside uv automatically before creating the furniture venv."
  fi

  if [[ "$force_full_install_from_master_env" != "1" && "$NON_INTERACTIVE" != "1" && "$reuse_existing_installation" == "1" ]]; then
    if ask_yes_no "An existing installation was detected. Do you want to reuse it without running setup again" "y"; then
      reuse_existing_installation="1"
      INSTALL_SYSTEM_DEPS="0"
    else
      reuse_existing_installation="0"
    fi
  fi

  if [[ "$force_full_install_from_master_env" != "1" && "$NON_INTERACTIVE" != "1" && "$INSTALL_SYSTEM_DEPS" != "1" && "$reuse_existing_installation" != "1" ]]; then
    if ask_yes_no "Do you want to reinstall or verify system dependencies anyway" "y"; then
      INSTALL_SYSTEM_DEPS="1"
    fi
  fi

  if [[ "$force_full_install_from_master_env" != "1" && "$NON_INTERACTIVE" != "1" && -d "$VENV_DIR" ]]; then
    if ask_yes_no "A previous .venv was found. Do you want to remove and recreate it" "y"; then
      RECREATE_VENV="1"
    fi
  elif [[ "$NON_INTERACTIVE" != "1" ]]; then
    echo "No previous .venv found. A new one will be created."
  fi

  if [[ "$use_last_config" == "1" ]]; then
    INSTALL_SYSTEM_DEPS="1"
    RECREATE_VENV="1"
    reuse_existing_installation="0"
  fi

  if [[ "$NON_INTERACTIVE" != "1" ]]; then
    print_question_group "Deployment Options"
    echo "Git repository updates may run automatically before launch so the furniture starts on the newest deployed app version."
  fi

  if [[ "$NON_INTERACTIVE" != "1" ]] && ask_yes_no "Do you want to keep a watcher that checks for changes every minute" "y"; then
    ENABLE_WATCH="1"
  fi

  if [[ "$NON_INTERACTIVE" != "1" ]] && ask_yes_no "Do you want to install a cron job to update at specific times" "n"; then
    INSTALL_CRON="1"
    CRON_SCHEDULE="$(ask "Cron expression for updates" "$CRON_SCHEDULE")"
  fi

  if [[ "$NON_INTERACTIVE" != "1" && "$first_run_without_systemd" != "1" ]] && ask_yes_no "Do you want to install/update systemd user services for auto-start" "y"; then
    INSTALL_SYSTEMD_USER="1"
  fi

  run_full_install_plan "$reuse_existing_installation"
}

parse_args() {
  if [[ $# -gt 0 ]]; then
    ARGS_PROVIDED="1"
  fi
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)
        MODE="$2"
        shift 2
        ;;
      --workspace)
        WORKSPACE_ROOT="$2"
        shift 2
        ;;
      --frontend-name)
        FRONTEND_REPO_NAME="$2"
        shift 2
        ;;
      --mqtt-name)
        MQTT_REPO_NAME="$2"
        shift 2
        ;;
      --branch)
        BRANCH_NAME="$2"
        shift 2
        ;;
      --run-update-once)
        RUN_UPDATE_ONCE="1"
        shift
        ;;
      --enable-watch)
        ENABLE_WATCH="1"
        shift
        ;;
      --install-cron)
        INSTALL_CRON="1"
        shift
        ;;
      --install-systemd-user)
        INSTALL_SYSTEMD_USER="1"
        shift
        ;;
      --cron-schedule)
        CRON_SCHEDULE="$2"
        shift 2
        ;;
      --app-language)
        APP_LANGUAGE="$2"
        shift 2
        ;;
      --device-id)
        DEVICE_ID="$2"
        shift 2
        ;;
      --videocall-room)
        VIDEOCALL_ROOM="$2"
        shift 2
        ;;
      --videocall-device-api-key)
        VIDEOCALL_DEVICE_API_KEY="$2"
        shift 2
        ;;
      --device-location)
        DEVICE_LOCATION="$2"
        shift 2
        ;;
      --hardware-mode)
        HARDWARE_MODE="$2"
        shift 2
        ;;
      --tts-engine)
        TTS_ENGINE="$2"
        shift 2
        ;;
      --tts-piper-bin)
        TTS_PIPER_BIN="$2"
        shift 2
        ;;
      --tts-piper-model-es)
        TTS_PIPER_MODEL_ES="$2"
        shift 2
        ;;
      --tts-piper-model-fr)
        TTS_PIPER_MODEL_FR="$2"
        shift 2
        ;;
      --tts-piper-model-es-male)
        TTS_PIPER_MODEL_ES_MALE="$2"
        shift 2
        ;;
      --tts-piper-model-es-female)
        TTS_PIPER_MODEL_ES_FEMALE="$2"
        shift 2
        ;;
      --tts-piper-model-fr-male)
        TTS_PIPER_MODEL_FR_MALE="$2"
        shift 2
        ;;
      --tts-piper-model-fr-female)
        TTS_PIPER_MODEL_FR_FEMALE="$2"
        shift 2
        ;;
      --tts-piper-model-es-url)
        TTS_PIPER_MODEL_ES_URL="$2"
        shift 2
        ;;
      --tts-piper-model-fr-url)
        TTS_PIPER_MODEL_FR_URL="$2"
        shift 2
        ;;
      --tts-piper-model-es-male-url)
        TTS_PIPER_MODEL_ES_MALE_URL="$2"
        shift 2
        ;;
      --tts-piper-model-es-female-url)
        TTS_PIPER_MODEL_ES_FEMALE_URL="$2"
        shift 2
        ;;
      --tts-piper-model-fr-male-url)
        TTS_PIPER_MODEL_FR_MALE_URL="$2"
        shift 2
        ;;
      --tts-piper-model-fr-female-url)
        TTS_PIPER_MODEL_FR_FEMALE_URL="$2"
        shift 2
        ;;
      --tts-piper-voice-es)
        TTS_PIPER_VOICE_ES="$2"
        shift 2
        ;;
      --tts-piper-voice-fr)
        TTS_PIPER_VOICE_FR="$2"
        shift 2
        ;;
      --recreate-venv)
        RECREATE_VENV="1"
        shift
        ;;
      --skip-system-deps)
        INSTALL_SYSTEM_DEPS="0"
        shift
        ;;
      --non-interactive)
        NON_INTERACTIVE="1"
        shift
        ;;
      --relaunch-after-update)
        RELAUNCH_AFTER_UPDATE="1"
        shift
        ;;
      --force-restart)
        FORCE_RESTART="1"
        shift
        ;;
      --yes)
        AUTO_CONFIRM="1"
        NON_INTERACTIVE="1"
        shift
        ;;
      --once)
        MODE="update-once"
        shift
        ;;
      --watch)
        MODE="watch"
        shift
        ;;
      --dry-run)
        MODE="dry-run"
        shift
        ;;
      --diagnose)
        MODE="diagnose"
        shift
        ;;
      --clean-launch)
        MODE="clean-launch"
        FORCE_RESTART="1"
        shift
        ;;
      --launch)
        MODE="launch"
        shift
        ;;
      --setup)
        MODE="setup"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  done
}

main() {
  init_colors
  parse_args "$@"
  if [[ "$MODE" != "update-once" ]]; then
    prepare_manual_launcher_takeover
    acquire_single_instance_lock
  fi
  resolve_paths
  normalize_device_identity
  dedupe_existing_update_cron_entries

  case "$MODE" in
    run)
      run_full_flow
      case "$MODE" in
        launch)
          check_paths
          load_env_file
          normalize_device_identity
          preflight_update_before_launch launch
          launch_runtime "$RELAUNCH_AFTER_UPDATE"
          if [[ "$ENABLE_WATCH" == "1" ]]; then
            log "Launch mode keeps watcher active."
            run_watch_loop
          else
            run_passive_supervision_loop
          fi
          ;;
        clean-launch)
          FORCE_RESTART="1"
          check_paths
          load_env_file
          normalize_device_identity
          preflight_update_before_launch clean-launch
          log "Clean launch requested: previous launcher/runtime state will be replaced."
          launch_runtime 0
          if [[ "$ENABLE_WATCH" == "1" ]]; then
            log "Clean launch keeps watcher active."
            run_watch_loop
          else
            run_passive_supervision_loop
          fi
          ;;
        setup)
          setup_environment
          ;;
        update-once)
          run_update_once launch
          ;;
        run)
          ;;
        *)
          ;;
      esac
      ;;
    setup)
      setup_environment
      ;;
    update-once)
      run_update_once launch
      ;;
    watch)
      run_watch_loop
      ;;
    launch)
      check_paths
      load_env_file
      normalize_device_identity
      preflight_update_before_launch launch
      launch_runtime "$RELAUNCH_AFTER_UPDATE"
      if [[ "$ENABLE_WATCH" == "1" ]]; then
        log "Launch mode keeps watcher active."
        run_watch_loop
      else
        run_passive_supervision_loop
      fi
      ;;
    clean-launch)
      FORCE_RESTART="1"
      check_paths
      load_env_file
      normalize_device_identity
      preflight_update_before_launch clean-launch
      log "Clean launch requested: previous launcher/runtime state will be replaced."
      launch_runtime 0
      if [[ "$ENABLE_WATCH" == "1" ]]; then
        log "Clean launch keeps watcher active."
        run_watch_loop
      else
        run_passive_supervision_loop
      fi
      ;;
    dry-run)
      print_dry_run
      ;;
    diagnose)
      log "Diagnose mode is read-only; active services are left untouched."
      print_diagnostics
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
