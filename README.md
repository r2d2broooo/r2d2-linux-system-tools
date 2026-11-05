# r2d2-linux-system-tools

Local backup, checkpoint, desktop setup, graphics setup and system-information utilities.

Preserve the workstation maintenance scripts independently from application code.

## Features

- Offline backup and restore guidance
- Explicit local Git checkpoints
- Desktop/graphics setup helpers
- System hardware information

## Use

python3 check.py; read each script before running it. Backup outputs contain private state and must stay outside GitHub.

Run `python3 check.py` for read-only source checks. These checks are not a claim
that external accounts, market feeds, hardware or a deployed service are configured.

## Snapshot and updates

Created on 2026-11-05 from the local R2D2 workspaces. This is a private source
snapshot; the original local workspaces remain the working copies. The catalogue
repo records every source and omission. Updates happen only on explicit operator
request; there is no automatic sync, push, hook or publishing timer.

Credentials, private chats/memory, live paper books, game saves, models, caches,
virtual environments and proprietary application binaries are not included.
Use a separate environment for this repo. Read USAGE.md/SETUP.md or the original
README where present. Existing integrations are documented rather than silently
starting account actions.
