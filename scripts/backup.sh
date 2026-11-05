#!/usr/bin/env bash
# Trading-system backup — everything needed to RESTORE or CLONE the system.
# Skips rebuildable virtualenvs (they're recreated from requirements on restore).
#   bash ~/backup.sh              -> core backup (code + .env + data + DBs + memory + schedule)
#   bash ~/backup.sh --with-models -> ALSO archive the Ollama models (7GB, incl. the custom fine-tune)
set -euo pipefail
TS=$(date +%Y%m%d_%H%M%S)
DEST="${BACKUP_DIR:-$HOME/backups}"
mkdir -p "$DEST"
CORE="$DEST/trading-system_${TS}.tar.gz"

echo "==> Freezing venv package lists (for rebuild on restore)…"
${R2D2_WORKSPACE:-$HOME}/telegram-bots/venv/bin/pip freeze > ${R2D2_WORKSPACE:-$HOME}/telegram-bots/requirements.txt 2>/dev/null || true

echo "==> Staging schedule + memory…"
STAGE=$(mktemp -d)
mkdir -p "$STAGE/systemd"
cp ~/.config/systemd/user/*.service ~/.config/systemd/user/*.timer "$STAGE/systemd/" 2>/dev/null || true
# Live memory moved from the old -home-r2d2-Desktop project to -home-r2d2 (audit 2026-07-24);
# the old path was silently backing up a stale 52-file snapshot while new memories went elsewhere.
cp -r ~/.claude/projects/-home-r2d2/memory "$STAGE/memory" 2>/dev/null || true

echo "==> Archiving core (code + secrets + data + DBs + schedule + memory)…"
# market_cache is excluded: it's the REBUILDABLE OHLCV archive (re-pulled from Yahoo by the
# nightly pre-warm) and it dominated the backup (650MB of ~700MB) while racing live writers
# ("file changed as we read it" + set -e aborted the script before the summary line).
tar --warning=no-file-changed -czf "$CORE" \
  --exclude='telegram-bots/venv' --exclude='telegram-bots/venv-train' \
  --exclude='dashboard/venv' --exclude='*/__pycache__' --exclude='*.pyc' \
  --exclude='*/node_modules' --exclude='telegram-bots/runs' \
  --exclude='dashboard/data/market_cache' \
  -C ${R2D2_WORKSPACE:-$HOME} telegram-bots dashboard trading-wiki \
  -C "$STAGE" systemd memory || [ $? -eq 1 ]
rm -rf "$STAGE"
echo "    CORE  -> $CORE  ($(du -h "$CORE" | cut -f1))"

if [ "${1:-}" = "--with-models" ]; then
  MODELS="$DEST/ollama-models_${TS}.tar.gz"
  echo "==> Archiving Ollama models (needs sudo; large)…"
  sudo tar -czf "$MODELS" -C /usr/share/ollama .ollama
  sudo chown "$USER":"$USER" "$MODELS"
  echo "    MODELS -> $MODELS  ($(du -h "$MODELS" | cut -f1))"
fi

# Rotation: keep the newest 4 core archives (~4 weeks at the weekly timer cadence).
ls -t "$DEST"/trading-system_*.tar.gz 2>/dev/null | tail -n +5 | xargs -r rm -f

echo ""
echo "Done. Copy the archive(s) OFF this machine (external drive / cloud) — the core"
echo "archive contains your .env secrets, so keep it private."
