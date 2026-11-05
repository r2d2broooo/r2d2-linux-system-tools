#!/bin/bash
# Save a safe backup (git checkpoint) of both projects.
#   ./checkpoint.sh "what I just changed"
# Revert later:
#   git -C <dir> log --oneline                 # list checkpoints
#   git -C <dir> checkout <hash> -- <file>     # restore one file
#   git -C <dir> reset --hard <hash>           # roll the whole repo back
MSG="${1:-checkpoint $(date '+%Y-%m-%d %H:%M')}"
for d in ${R2D2_WORKSPACE:-$HOME}/dashboard ${R2D2_WORKSPACE:-$HOME}/telegram-bots; do
  git -C "$d" add -A
  if git -C "$d" -c user.email="contact@example.invalid" -c user.name="R2D2" commit -qm "$MSG"; then
    echo "✓ checkpoint saved: $d"
  else
    echo "· no changes: $d"
  fi
done
