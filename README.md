# CoBien Furniture App Launcher

This repository is the deployment and lifecycle control layer for CoBien furniture devices.

Its long-term goal is to own the full furniture bootstrap and runtime orchestration flow, while the application repositories remain focused on the runtime code they ship.

At the moment, this repository already contains the system bootstrap script, the extracted launcher entrypoint, user-level systemd helpers, and deployment environment templates.

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

System bootstrap script for a fresh Ubuntu furniture device.

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

### `cobien-launcher.sh`

Main operational entrypoint for the furniture runtime.

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

This script is the core of the deployment controller design.

### `install-systemd-user.sh`

Installs and refreshes the user-level systemd units and autostart hooks required by the furniture runtime.

It also:

- enables linger when available
- installs a graphical-session environment import helper
- updates the Openbox autostart hook
- removes legacy cron-based update entries
- enables and starts the current launcher services

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

Today, the furniture deployment flow is split into two layers.

### Layer 1: system bootstrap

Handled by `setup-cobien-furniture-environment.sh`.

This layer prepares the Ubuntu device itself.

### Layer 2: runtime lifecycle management

Handled by `cobien-launcher.sh` and the `systemd` scripts.

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

If the launcher owns installation, updates, and launch behavior, then it must also own:

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

## Recommended workflow today

### For a fresh target device

1. Clone this repository into the workspace.
2. Review and adapt the deployment env template.
3. Run the bootstrap script only on the target furniture device.
4. Let the launcher install or refresh the runtime environment.
5. Install the user-level systemd services.

### For an existing target device

1. Update this repository first.
2. Review changes to launcher behavior, units, and env templates.
3. Refresh the systemd user installation if required.
4. Trigger a one-shot update or restart through the launcher service.

## Important operational constraints

- Do not run the bootstrap script on a development machine.
- Do not treat the frontend repository as the long-term home of deployment logic.
- Do not manually edit generated runtime files unless you are debugging the launcher itself.
- Do not assume the current `~/cobien` layout is the final long-term workspace contract.

## Architecture notes

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for a deeper explanation of repository boundaries, migration goals, and the target deployment model.
