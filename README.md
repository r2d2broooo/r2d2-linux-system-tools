# R2D2 Linux System Tools

A small collection of workstation maintenance scripts kept separate from application code. It preserves useful backup, checkpoint, desktop setup and hardware-inspection work without distributing a machine image, installed applications or private configuration.

These scripts have operational effects when explicitly run. They are examples to inspect and configure for the target host, not an installer that should be executed wholesale.

## Included tools

| Tool | Role |
|---|---|
| `scripts/backup.sh` | Creates an offline recovery archive of configured application/state folders; optional model backup support |
| `scripts/checkpoint.sh` | Makes local Git checkpoints of the configured source workspaces; it does not push |
| `scripts/desktop-control-setup*.sh` | Records desktop-automation setup steps and prerequisites |
| `scripts/install-nvidia.sh` | A host-specific graphics setup helper requiring local review |
| `scripts/make_montage.py` | Combines local images into a contact-sheet-style artifact |
| `sysinfo.py` | Reads available CPU/GPU/memory/disk information |
| `bin/paseo-desktop` and `desktop/` | Launcher wrappers; the underlying applications are external dependencies |

## Use and configuration

Run the source checks first:

```bash
python3 check.py
```

Then inspect the selected script's paths, environment variables, command-line arguments, package-manager assumptions and privilege requirements. `R2D2_WORKSPACE` is used by adapted workspace paths where available; user-service/desktop examples also require installation-path review.

There is no need to run backup, graphics installation or desktop setup merely to inspect this repository. No timer is installed and no service is started by cloning it.

## Backup privacy

An offline recovery archive may intentionally contain environment files, databases, model state and other private material. That is different from a shareable source repository. Keep recovery archives outside GitHub and protect them as private backups. No such archive is included here.

The source includes historical restore guidance under `historical/`. It may describe retired models or an older application layout. Use the current trading/workspace documentation for the current architecture rather than treating an old recovery note as an active deployment contract.

## Dependencies and verification

Requirements vary by tool: Bash/Git/archive utilities for checkpoint/backup work, Python and image tools for the montage helper, desktop/X11 packages for automation, and a suitable Linux package/driver environment for graphics setup. Paseo and provider CLIs must be installed independently.

Syntax/source checks have been run without installing a driver, changing a network, touching accounts, restoring a backup or restarting a service. Hardware information is read at runtime; no source workstation inventory, account configuration, addresses or personal contact details are bundled.

## Privacy, provenance and updates

This repository is a sanitized source export. No provider credentials, personal contact information, configured IP addresses, private conversations or runtime databases are included. Example hostnames and local environment variables are intentional. Keep newly generated account data and captures outside version control.

A source manifest records exported files. Local adaptations and third-party material retain their own provenance/notices; public visibility does not apply a new blanket license to every file. Related repositories and the manual update process are listed in the [workspace catalogue](https://github.com/r2d2broooo/r2d2-workspace-catalog).

Updates are made only on explicit request. Cloning does not enable an automatic sync, scheduled publication or Git push.
