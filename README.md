# CoBien Furniture App Launcher

This repository is the deployment and lifecycle control layer for CoBien furniture devices.

Its long-term goal is to own the full furniture bootstrap and runtime orchestration flow, while the application repositories remain focused on the runtime code they ship.

At the moment, this repository already contains the system bootstrap script, the extracted launcher entrypoint, internal compatibility helpers, and deployment environment templates.

## Repository purpose

This repository exists to centralize all furniture-specific operational responsibilities in one place.

That includes:

- provisioning a target Ubuntu machine
- preparing the desktop/session environment used by the furniture device
- cloning or updating the CoBien runtime repositories
- installing and refreshing user-level systemd units
- driving runtime setup, updates, and launch operations
- owning deployment-facing environment templates and generated runtime env files

The intended design is that deployment logic lives here, while application logic remains in the runtime repositories.

## What this repository is not

This repository is not the CoBien furniture runtime itself.

The actual application code still lives in external repositories, currently:

- `cobien_FrontEnd`
- `cobien_MQTT_Dictionnary`

This repository orchestrates those payload repositories. It does not replace them.

## Safety notice

This repository targets furniture devices, not the local development workstation.

The bootstrap script is blocked by default and aborts immediately unless the caller explicitly opts in with:

```bash
COBIEN_ALLOW_SYSTEM_PROVISIONING=yes
```

This safeguard exists to prevent accidental execution on a developer machine.

## Current repository layout

```text
cobien-furniture-app-launcher/
├── README.md
├── cobien-launcher.sh
├── import-systemd-user-env.sh
├── install-systemd-user.sh
├── setup-cobien-furniture-environment.sh
├── systemd/
│   ├── cobien-launcher.service
│   ├── cobien-update.service
│   └── cobien-update.timer
└── templates/
	├── cobien.env.example
	└── cobien-update.env.example
```

## File-by-file responsibility

### `setup-cobien-furniture-environment.sh`

Official and only supported human entrypoint for a fresh Ubuntu furniture device.

It is responsible for:

- installing system packages such as Openbox, LightDM, and PipeWire
- selecting the invoking user as the target furniture user
- configuring autologin into Openbox
- applying the furniture display layout, including the default inverted rotation used by upside-down hardware installations
- creating the workspace directory
- cloning or updating the runtime repositories
- installing RustDesk and wiring it into the Openbox session
- creating Openbox startup hooks for the furniture graphical session and launcher handoff
- preparing the CoBien runtime in setup mode without launching it immediately
- installing the user-level systemd units so the app starts naturally after reboot

This script changes system state and must only be run on a target device.
If you are deploying or reinstalling a furniture device, this is the script you should run.

### `cobien-launcher.sh`

Internal runtime controller used by the setup flow and by user services after installation.

It is responsible for:

- loading deployment configuration
- resolving workspace, frontend, and MQTT repository paths
- preparing Python and the virtual environment
- configuring runtime dependencies
- generating the runtime env file
- generating or refreshing the frontend local config
- checking for updates
- launching the bridge and the frontend runtime
- supporting unattended, setup-only, launch-only, update-only, dry-run, and diagnose modes

This script is still the core runtime controller, but it is no longer the recommended human entrypoint for a furniture deployment.

### `install-systemd-user.sh`

Retired compatibility entrypoint kept only to fail clearly.

Systemd installation is owned exclusively by:

- `setup-cobien-furniture-environment.sh`

The launcher no longer installs or rewrites its own user services. If this
wrapper is called, it prints the official setup command and exits without
changing the machine. This prevents an old operational habit from silently
using a second provisioning path.

### `import-systemd-user-env.sh`

Imports graphical session variables such as `DISPLAY`, `XAUTHORITY`, and `DBUS_SESSION_BUS_ADDRESS` into `systemd --user` so that the launcher service can inherit the active desktop session context.

### `systemd/*`

User-level systemd units owned by this repository.

Current units:

- `cobien-launcher.service`: main runtime supervision
- `cobien-update.service`: one-shot update check
- `cobien-update.timer`: scheduled update trigger

### `templates/cobien.env.example`

Human-maintained deployment configuration template.

This file defines the main deployment-facing settings such as workspace, branch, device identity, backend URLs, and runtime feature configuration.

It also carries the furniture display settings used during system bootstrap, including output name, resolution, and rotation.

### `templates/cobien-update.env.example`

Generated-runtime-env reference template.

This file represents the kind of derived values the launcher writes after resolving paths, defaults, and deployment settings.

## Current operational model

Today, the operational code still has internal layers, but the supported deployment flow has already been collapsed into one official script.

### Layer 1: system bootstrap

Handled by `setup-cobien-furniture-environment.sh`.

This layer prepares the Ubuntu device itself.

### Layer 2: runtime lifecycle management

Handled internally by `cobien-launcher.sh` and the installed `systemd` user units.

This layer owns setup, update checks, launch, restart, and runtime supervision.

## Current dependency model

This repository currently assumes the following workspace layout:

```text
~/cobien/
├── cobien-furniture-app-launcher/
├── cobien_FrontEnd/
└── cobien_MQTT_Dictionnary/
```

The launcher repository is now the owner of:

- the launcher entrypoint
- systemd installation helpers
- deployment templates
- generated runtime env location

The frontend repository is still the owner of:

- the Kivy application runtime
- `mainApp.py`
- Python project definition
- `config.default.json`
- local generated `config.local.json`

The MQTT repository is still the owner of:

- the CAN bridge source code
- bridge build assets
- conversion definitions

## Current migration status

The migration is in progress.

Already moved into this repository:

- bootstrap script
- main launcher script
- systemd install helper
- session-env import helper
- systemd unit files
- deployment env templates

Not fully decoupled yet:

- the generated `config.local.json` still lives inside `cobien_FrontEnd/app/config`
- the Python virtual environment still lives inside `cobien_FrontEnd/app/.venv`
- the actual runtime entrypoint remains `cobien_FrontEnd/app/mainApp.py`
- some default paths still assume `~/cobien` as the workspace root

That means this repository already owns the deployment logic, but the runtime state model is not fully separated from the frontend repository yet.

## How configuration works right now

There are two configuration concepts in the current design.

### Main deployment env

The main human-maintained deployment configuration is `cobien.env`.

This is the file that should contain the desired target-device settings such as:

- device identity
- selected branch
- backend URLs
- runtime feature toggles
- hardware mode
- TTS configuration

### Derived runtime env

The launcher generates `cobien-update.env` as a derived runtime env file.

It contains resolved runtime values such as:

- concrete repository paths
- effective branch and remote
- selected workspace root
- the selected master env file path
- the effective runtime values used to launch the device

The current design therefore distinguishes between:

- human input configuration
- launcher-generated resolved configuration

## Why the templates live here

The templates belong in this repository because they are part of deployment policy, not application logic.

If this repository owns installation, updates, and launch behavior, then it must also own:

- the deployment env contract
- the runtime env contract
- the systemd contract

Keeping those templates in the frontend repository would keep the deployment responsibility in the wrong place.

## systemd model

This repository currently provides a user-level supervision model.

The default design is:

- `cobien-launcher.service` keeps the main runtime supervised
- `cobien-update.timer` schedules periodic update checks
- `cobien-update.service` performs the actual one-shot update check
- `import-systemd-user-env.sh` bridges the graphical session into `systemd --user`

The setup script is the only code path that installs or refreshes these units.
The launcher treats a missing `cobien-launcher.service` as an incomplete
device provisioning and stops with instructions to rerun the setup script.

This avoids relying on ad hoc shell startup files or legacy autostart entries as the main runtime strategy.

## Openbox and desktop integration

The bootstrap layer prepares Openbox as the device session shell.

The user-level systemd layer then integrates into that session by importing the real graphical environment into user services.

This split is intentional:

- system provisioning configures the desktop session
- runtime orchestration runs inside the user session

## User handling model

The repository is intended to be agnostic to a fixed furniture username.

The bootstrap script uses the invoking user as the target furniture account.

When the script is run through `sudo`, it still resolves the original user instead of blindly configuring `root`.

This prevents the deployment model from depending on a hardcoded username such as `cobien`.

## What still needs to improve

The current state is already usable as a deployment-control repository, but it is not the final architecture yet.

The next major improvements are:

- move generated env files out of ad hoc root-level paths into a dedicated launcher-owned config directory
- move persistent launcher state into a launcher-owned state directory
- stop coupling local generated configuration to the frontend repository layout
- define a release or manifest model so that frontend and MQTT updates are coordinated
- document the stable contract between launcher and runtime repositories

## Deploying a new device

### Prerequisites

- A machine running Ubuntu 22.04 LTS (physical furniture or VM).
- The device must be registered in the CoBien admin portal with its own device ID and API keys.
- This repository must be cloned on the target machine before running the bootstrap script.
- The runtime repositories (`cobien_FrontEnd`, `cobien_MQTT_Dictionnary`) are public and do not require SSH credentials.

### Step-by-step bootstrap

```bash
# 1. Clone the launcher repository on the target machine.
mkdir -p ~/cobien
git clone https://github.com/DeustoTech/cobien-furniture-app-launcher ~/cobien/cobien-furniture-app-launcher

# 2. Run the bootstrap script.
#    The safety gate requires COBIEN_ALLOW_SYSTEM_PROVISIONING=yes.
cd ~/cobien/cobien-furniture-app-launcher
sudo COBIEN_ALLOW_SYSTEM_PROVISIONING=yes bash setup-cobien-furniture-environment.sh
```

The script will:
- Install system packages (Openbox, LightDM, PipeWire, can-utils, Mosquitto, etc.).
- Prompt whether to download the device configuration from the CoBien admin portal.
  Enter your admin credentials and select the furniture device to configure.
- Clone the frontend and MQTT repositories.
- Configure the Openbox session and LightDM autologin.
- Install RustDesk (unless disabled in the device configuration).
- Run `cobien-launcher.sh --mode setup` to prepare the Python environment and TTS models.
- Install the user-level systemd units.
- Reboot automatically (unless disabled in the device configuration).

After the reboot, LightDM logs the furniture user in automatically, Openbox starts, and
`cobien-launcher.service` brings up the full runtime.

### Re-running the bootstrap

The bootstrap script is idempotent. Running it again on an already-configured device:
- Updates system packages only if the versions changed.
- Pulls the latest commits in the frontend and MQTT repositories.
- Checks for unexpected files in those repositories and offers to clean them.
- Refreshes the systemd units and Openbox session configuration.

## Web portal per-device configuration

Each device in the CoBien admin portal has a JSON field that defines its device-specific settings.
The portal combines this JSON with global server-side defaults (device ID, API keys, backend URL)
and serves the result as `cobien.env` when the setup script requests it.

The following fields are injected automatically by the server and must **not** be duplicated in the
per-device JSON:

| Field | Source |
|---|---|
| `COBIEN_DEVICE_ID` | Device record in the portal database |
| `COBIEN_VIDEOCALL_ROOM` | Device record in the portal database |
| `COBIEN_NOTIFY_API_KEY` | Device record in the portal database |
| `COBIEN_VIDEOCALL_DEVICE_API_KEY` | Device record in the portal database |
| `COBIEN_BACKEND_BASE_URL` | Global server default |
| All derived URLs (`COBIEN_DEVICE_POLL_URL`, `COBIEN_PIZARRA_*`, etc.) | Auto-derived from `COBIEN_BACKEND_BASE_URL` by the launcher |

### Real furniture device

```json
{
  "COBIEN_APP_LANGUAGE": "es",
  "COBIEN_DEVICE_LOCATION": "Bilbao",
  "COBIEN_SETTINGS_PIN": "1234",
  "COBIEN_RESTART_PIN": "9999",
  "COBIEN_WEATHER_PRIMARY_CITY": "Bilbao",
  "COBIEN_DISABLE_SYSTEM_SLEEP": "1"
}
```

The launcher defaults are already correct for physical hardware:
`COBIEN_HARDWARE_MODE=auto` (detects CAN bus), `COBIEN_DISPLAY_OUTPUT=eDP-1`,
`COBIEN_DISPLAY_MODE=1920x1200`, `COBIEN_DISPLAY_ROTATION=inverted`,
`COBIEN_INSTALL_RUSTDESK=1`, `COBIEN_AUTO_REBOOT_AFTER_SETUP=1`.
None of those need to appear in the per-device JSON unless the specific device differs from the standard.

### Virtual machine (testing)

VMs require explicit overrides because the launcher defaults target physical hardware.

```json
{
  "COBIEN_APP_LANGUAGE": "es",
  "COBIEN_DEVICE_LOCATION": "Laboratorio",
  "COBIEN_SETTINGS_PIN": "1234",
  "COBIEN_RESTART_PIN": "9999",
  "COBIEN_WEATHER_PRIMARY_CITY": "Bilbao",
  "COBIEN_HARDWARE_MODE": "mock",
  "COBIEN_DISPLAY_OUTPUT": "HDMI-1",
  "COBIEN_DISPLAY_MODE": "1920x1080",
  "COBIEN_DISPLAY_ROTATION": "normal",
  "COBIEN_DISABLE_SYSTEM_SLEEP": "0",
  "COBIEN_INSTALL_RUSTDESK": "0",
  "COBIEN_AUTO_REBOOT_AFTER_SETUP": "0"
}
```

`COBIEN_HARDWARE_MODE=mock` disables CAN bus setup, CAN logging, and the MQTT-CAN bridge.
The frontend app still starts and connects to the local Mosquitto broker.

The value of `COBIEN_DISPLAY_OUTPUT` depends on the hypervisor:

| Hypervisor | Typical output name |
|---|---|
| VirtualBox | `VGA-1` or `Virtual-1` |
| VMware | `Virtual1` |
| KVM / QEMU | `Virtual-1` |

If the display output name is wrong, `xrandr` fails silently and the screen uses whatever
resolution the hypervisor provides. That is acceptable for testing.

## Keeping devices up to date

The runtime repositories (`cobien_FrontEnd`, `cobien_MQTT_Dictionnary`) are public.
Devices pull updates via HTTPS and do not require SSH credentials or deploy keys.

### How automatic updates work

After the initial setup, two mechanisms keep devices up to date:

1. **`cobien-update.timer`** — systemd timer that triggers `cobien-update.service` once per day at
   01:00 with a random delay of up to 5 minutes to avoid all devices hitting GitHub simultaneously.

2. **Watch loop** — when `COBIEN_ENABLE_WATCH=1`, the launcher polls git every
   `COBIEN_UPDATE_INTERVAL_SEC` seconds (default: 60) while the runtime is active.

On each update check the launcher:
1. Stops the running app.
2. Pulls the launcher repository itself. If the launcher script changed, it hands off execution
   to the new version before continuing.
3. Pulls `cobien_FrontEnd` and `cobien_MQTT_Dictionnary`.
4. Restarts the app if any repository changed.

### Pushing an update

```bash
# In cobien_FrontEnd or cobien_MQTT_Dictionnary:
git push origin master
```

Devices on the daily timer will pick up the change within 25 hours.
Devices with the watch loop enabled will pick it up within `COBIEN_UPDATE_INTERVAL_SEC` seconds.

### Forcing an immediate update on a device

```bash
# Trigger the update service manually.
systemctl --user start cobien-update.service

# Or run the launcher directly in update-once mode.
~/cobien/cobien-furniture-app-launcher/cobien-launcher.sh \
  --mode update-once --non-interactive --yes

# Watch the update in real time.
journalctl --user -u cobien-update.service -f
journalctl --user -u cobien-launcher.service -f
```

### Checking the status of a device

```bash
# Service status.
systemctl --user status cobien-launcher.service
systemctl --user status cobien-update.timer

# Last launcher output.
journalctl --user -u cobien-launcher.service -n 50

# Diagnose mode (read-only, no changes).
~/cobien/cobien-furniture-app-launcher/cobien-launcher.sh --mode diagnose
```

## Recommended workflow today

### For a fresh target device

1. Register the device in the CoBien admin portal and fill in its per-device JSON (see above).
2. Clone this repository on the target machine.
3. Run the bootstrap script with `COBIEN_ALLOW_SYSTEM_PROVISIONING=yes`.
4. Download the device configuration from the portal when the script prompts for it.
5. The script handles everything else. Reboot when finished.

### For an existing target device

1. Push changes to the relevant runtime repository on GitHub.
2. Trigger `systemctl --user start cobien-update.service` on the device, or wait for the daily timer.
3. The launcher pulls, detects the change, and restarts the app automatically.
4. If the launcher script itself changed, re-run the bootstrap script to refresh the systemd units.

## Important operational constraints

- Do not run the bootstrap script on a development machine.
- Do not treat the frontend repository as the long-term home of deployment logic.
- Do not manually edit generated runtime files unless you are debugging the launcher itself.
- Do not assume the current `~/cobien` layout is the final long-term workspace contract.

## Architecture notes

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for a deeper explanation of repository boundaries, migration goals, and the target deployment model.
