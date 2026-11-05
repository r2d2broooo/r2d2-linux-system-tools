# Restore / clone the trading system

You have two archives from `backup.sh`:
- `trading-system_<ts>.tar.gz` — **core**: code, `.env` secrets, `dashboard/data` (incl. the trained
  `meta_model.joblib`), the SQLite DBs (`chat_log.db` = chat history + idea map + tasks/notes,
  `fundamentals.db`, `research.db`), prompts, systemd units, and the memory files.
- `ollama-models_<ts>.tar.gz` — **models** (only if you ran `--with-models`): the Ollama blob store,
  including the **custom fine-tuned `minicpm-v-chart`** (this one can't be re-downloaded — the base
  MiniCPM/others can).

## New machine — one-time setup
1. Install: `python3.11+`, `pip`, `git`, and **Ollama** (https://ollama.com), plus Tailscale if you use it.
2. Restore the core:
   ```bash
   cd ~ && tar -xzf trading-system_<ts>.tar.gz
   mkdir -p ~/.config/systemd/user && cp systemd/*.service systemd/*.timer ~/.config/systemd/user/
   mkdir -p ~/.claude/projects/-home-user-Desktop && cp -r memory ~/.claude/projects/-home-user-Desktop/
   ```
3. Rebuild the virtualenvs (NOT backed up — they're machine-specific):
   ```bash
   cd ~/telegram-bots && python3 -m venv venv && venv/bin/pip install -r requirements.txt
   cd ~/dashboard     && python3 -m venv venv && venv/bin/pip install -r requirements.txt
   ```
4. Restore the models:
   ```bash
   # if you have the models archive:
   sudo tar -xzf ollama-models_<ts>.tar.gz -C /usr/share/ollama
   sudo systemctl restart ollama && ollama list      # confirm minicpm-v-chart + minicpm-v-local are there
   # if you DON'T: re-pull the base, but the fine-tune must come from the archive
   ollama pull minicpm-v         # base only — the fine-tuned chart model is not on any registry
   ```
5. Check paths + secrets: the code uses absolute `<workspace>/...` paths. If the new user isn't `r2d2`,
   either create that user or grep-replace `<workspace>` across `telegram-bots` + `dashboard`. Confirm
   both `.env` files came through (`telegram-bots/.env`, `dashboard/.env`).
6. Enable the schedule + start services:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now dashboard telegram-claude-bot telegram-llm-bot
   systemctl --user enable --now watchdog.timer trading-brief.timer   # + the other *.timer units
   ```

## Same machine — disaster recovery
Just `tar -xzf` the core archive over `~/`, restore models if the Ollama store was lost, and
`systemctl --user restart` the services. The DBs/`.env`/models are all in the archives.

## Recommended: also push code to a private git remote
Both projects are git repos with no remote. A private GitHub/GitLab repo gives you off-machine,
versioned code backup (does NOT include `.env`/data — those stay in `backup.sh`):
```bash
cd ~/telegram-bots && git remote add origin contact@example.invalid:<you>/telegram-bots.git && git push -u origin HEAD
cd ~/dashboard     && git remote add origin contact@example.invalid:<you>/dashboard.git     && git push -u origin HEAD
```

## Cadence
Run `bash ~/backup.sh` after meaningful changes (weekly is plenty; the core is small).
Run `--with-models` only when the fine-tuned model changes (rare — it's 7GB).
Keep at least one copy OFF this machine. The core archive holds secrets — store it privately.
