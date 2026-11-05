#!/usr/bin/env bash
# Reinstall the proprietary NVIDIA driver (595-open) on r2d2.
# Context: the 580-open stack was removed 2026-08-25 14:12 via PackageKit, which
# dropped the box to nouveau. Nouveau then killed Chrome's GPU channel on every
# render (Xid:13 WIDTH CT Violation), freezing the browser.
#
# Uses Canonical PRE-SIGNED kernel modules, so Secure Boot needs no MOK enrollment.
set -euo pipefail

KVER="$(uname -r)"
BRANCH="595-open"
echo "==> kernel: $KVER   target driver: nvidia-driver-$BRANCH"

echo "==> refreshing package lists"
apt-get update

echo "==> confirming a SIGNED module exists for this exact kernel (no DKMS, no MOK prompt)"
MOD="linux-modules-nvidia-${BRANCH}-${KVER}"
apt-cache show "$MOD" >/dev/null 2>&1 || { echo "FATAL: $MOD not available. ABORTING - do not reboot."; exit 1; }
echo "    ok: $MOD"

echo "==> installing driver + signed modules"
apt-get install -y \
  "nvidia-driver-${BRANCH}" \
  "linux-modules-nvidia-${BRANCH}-generic-hwe-24.04" \
  "$MOD"

echo
echo "==> POST-INSTALL VERIFICATION (all must pass before you reboot)"
fail=0

if [ -f "/lib/modules/$KVER/kernel/nvidia-${BRANCH%-open}"*/nvidia.ko* ] 2>/dev/null || \
   find "/lib/modules/$KVER" -name 'nvidia*.ko*' -print -quit | grep -q .; then
  echo "  [ok] nvidia kernel module present for $KVER"
else
  echo "  [FAIL] no nvidia .ko found for $KVER"; fail=1
fi

if modinfo nvidia >/dev/null 2>&1; then
  echo "  [ok] modinfo nvidia resolves: $(modinfo -F version nvidia 2>/dev/null || echo '?')"
  sig=$(modinfo -F signer nvidia 2>/dev/null || true)
  [ -n "$sig" ] && echo "  [ok] module signed by: $sig" || { echo "  [WARN] module reports no signer - Secure Boot may reject it"; fail=1; }
else
  echo "  [FAIL] modinfo nvidia failed"; fail=1
fi

if ls /etc/modprobe.d/ 2>/dev/null | grep -q nvidia && grep -rqs 'blacklist nouveau' /etc/modprobe.d/; then
  echo "  [ok] nouveau blacklisted"
else
  echo "  [WARN] nouveau not blacklisted - the driver package usually handles this"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "############################################################"
  echo "VERIFICATION FAILED - DO NOT REBOOT."
  echo "Roll back with:  sudo apt-get install --reinstall -y xserver-xorg-video-nouveau"
  echo "############################################################"
  exit 1
fi

echo "############################################################"
echo "All checks passed. Reboot to load the driver:   sudo reboot"
echo
echo "After reboot, confirm with:  nvidia-smi"
echo "If you land on a black screen: at GRUB pick 'Advanced' ->"
echo "recovery mode -> root shell, then:"
echo "  apt-get purge -y 'nvidia-*' && apt-get install --reinstall -y xserver-xorg-video-nouveau && reboot"
echo "############################################################"
