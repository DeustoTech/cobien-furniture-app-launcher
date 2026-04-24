# CoBien Furniture Launcher Architecture

## Overview

The CoBien furniture deployment model is being reshaped so that deployment responsibility lives in one repository and runtime responsibility lives in the runtime repositories.

This repository is the deployment-control repository.

Its purpose is to own:

- system bootstrap
- launcher logic
- update orchestration
- user-level service installation
- deployment-facing configuration templates
- the contract used to run a furniture device

## Repository boundaries

### `cobien-furniture-app-launcher`

Owns the operational lifecycle of a furniture device.

That includes:

- preparing the Ubuntu target machine
- defining how repositories are cloned and updated
- defining how user services are installed and restarted
- deciding how deployment env files are loaded and generated
- deciding how the runtime is launched

### `cobien_FrontEnd`

Owns the furniture application runtime.

That includes:

- `mainApp.py`
- application Python project files
- frontend runtime logic
- default config schema and local generated config schema

It should not remain the owner of deployment orchestration in the long term.

### `cobien_MQTT_Dictionnary`

Owns the CAN and MQTT bridge implementation and related assets.

That includes:

- bridge build files
- bridge source code
- conversion configuration

It is a payload repository, not a deployment controller.

## Current architecture

The current architecture is transitional.

The launcher repository already owns the launcher entrypoint and deployment helpers, but some runtime state still depends on frontend-local paths.

Current path assumptions still present:

- frontend runtime in `cobien_FrontEnd/app`
- frontend local generated config in `cobien_FrontEnd/app/config/config.local.json`
- frontend virtual environment in `cobien_FrontEnd/app/.venv`
- workspace root default in `~/cobien`

These assumptions are acceptable during migration, but they should not define the final architecture.

## Target architecture

The target model is a three-layer design.

### 1. Bootstrap layer

Prepares the operating system and desktop environment.

Examples:

- package installation
- LightDM/Openbox configuration
- SSH enablement
- session startup preparation

### 2. Control layer

Lives in this repository and owns the lifecycle of the device software.

Examples:

- launcher entrypoint
- repository synchronization
- version coordination
- runtime env generation
- service installation and supervision
- rollout and restart behavior

### 3. Runtime layer

Lives in the application repositories and contains the actual software executed on the furniture device.

Examples:

- frontend UI runtime
- CAN and MQTT bridge runtime

## Configuration model

The intended long-term configuration split is:

- a human-maintained deployment config
- a launcher-generated resolved runtime config
- a device-local mutable state/config store

The deployment-control repository should own the first two.

The frontend should only consume the resulting runtime configuration contract.

## Why this split matters

Frontend and MQTT repositories can evolve frequently and independently.

If deployment policy stays inside a runtime repository, then:

- release coordination becomes unclear
- deployment behavior changes are coupled to application code changes
- ownership boundaries remain blurred
- long-term maintenance becomes harder

By moving deployment ownership here, the operational contract becomes explicit.

## Update strategy

The best long-term model is for this repository to coordinate updates rather than letting each payload repository update itself independently.

That means the launcher repository should eventually define:

- which repositories are required
- which branch, tag, or commit should be used for each payload
- when and how updates are applied
- when a restart is required

This is the foundation for a manifest-driven deployment model.

## Username and workspace assumptions

The launcher should not depend on a fixed Linux username.

The bootstrap layer already uses the invoking user rather than a hardcoded account.

The next step is to reduce path assumptions such as:

- fixed home-based workspace roots
- frontend-owned locations for launcher-generated assets

The final architecture should rely on launcher-owned root variables such as:

- `COBIEN_HOME`
- `COBIEN_CONFIG_DIR`
- `COBIEN_STATE_DIR`
- `COBIEN_RUNTIME_DIR`

## Migration priorities

### Priority 1

Complete extraction of deployment assets into this repository.

### Priority 2

Make launcher-owned config and generated env files independent from frontend-local paths.

### Priority 3

Move launcher state, logs, and runtime metadata into launcher-owned directories.

### Priority 4

Introduce a coordinated version or manifest model for multi-repository releases.

## Practical reading of the current state

Today, this repository is already the correct home for installation, update, and launch logic.

What remains is to finish the decoupling work so that runtime repositories are treated as payloads rather than partial deployment owners.