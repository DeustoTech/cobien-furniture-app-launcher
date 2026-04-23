# CoBien Furniture App Launcher

Base repository for preparing an Ubuntu installation for CoBien furniture devices with Openbox as the main window manager.

## Notice

This repository contains an installer for the target CoBien furniture devices.

It must not be executed on this development machine.

The script is blocked by default and only runs when `COBIEN_ALLOW_SYSTEM_PROVISIONING=yes` is explicitly provided.

## Current contents

- `setup-cobien-furniture-environment.sh`: main environment setup script for CoBien furniture devices.

## What the installer does

- Installs the base system packages required for Openbox, LightDM, audio, and remote access.
- Detects the current invoking user and uses that account for autologin and user-level startup files.
- Creates the `~/cobien` working directory.
- Clones or updates the `cobien_FrontEnd` and `cobien_MQTT_Dictionnary` repositories on the `development_fix` branch.
- Enables SSH.
- Configures LightDM autologin into an Openbox session.
- Generates the Openbox startup scripts required to launch basic services and RustDesk.
- Validates the Openbox session and performs a safe cleanup with `apt autoremove`.

## Usage

```bash
chmod +x setup-cobien-furniture-environment.sh
COBIEN_ALLOW_SYSTEM_PROVISIONING=yes ./setup-cobien-furniture-environment.sh
```

## Requirements and notes

- The script is intended for Ubuntu systems with `apt`.
- It requires `sudo` privileges.
- When executed with `sudo`, it still targets the original invoking user instead of `root`.
- RustDesk is not installed automatically; it must be installed and configured before the final reboot.

## Planned next iterations

- Parameterize the branch, screen resolution, and installation path.
- Add system preflight checks.
- Automate more parts of the furniture remote startup flow.