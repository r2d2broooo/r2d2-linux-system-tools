#!/bin/bash
set -e

echo "=== 1. Installing packages ==="
sudo apt update
sudo apt install -y ydotool imagemagick xdotool scrot

echo
echo "=== 2. ydotoold help (checking available flags) ==="
ydotoold --help || true

echo
echo "=== 3. Setting up ydotoold systemd service ==="
sudo mkdir -p /run/ydotool
sudo tee /etc/systemd/system/ydotoold.service > /dev/null <<'EOF'
[Unit]
Description=ydotool daemon
After=local-fs.target

[Service]
ExecStart=/usr/bin/ydotoold --socket-path=/run/ydotool/ydotool.socket --socket-perm=0666
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now ydotoold
sleep 1
sudo systemctl status ydotoold --no-pager | head -10

echo
echo "=== 4. Testing ydotool input (moves mouse 5px, should be harmless) ==="
export YDOTOOL_SOCKET=/run/ydotool/ydotool.socket
ydotool mousemove_relative -- 5 5 && echo "ydotool mouse move: OK" || echo "ydotool mouse move: FAILED"

echo
echo "=== 5. Testing screenshot via GNOME D-Bus Shell.Screenshot ==="
gdbus call --session --dest org.gnome.Shell.Screenshot --object-path /org/gnome/Shell/Screenshot --method org.gnome.Shell.Screenshot.Screenshot true false /tmp/test_shell_ss.png 2>&1 || true
ls -la /tmp/test_shell_ss.png 2>/dev/null && echo "Shell.Screenshot: OK" || echo "Shell.Screenshot: FAILED/DENIED"

echo
echo "=== 6. Testing screenshot via xdg-desktop-portal (may prompt a dialog on screen) ==="
gdbus call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.Screenshot.Screenshot "" 0 '{}' 2>&1 || true

echo
echo "=== 7. Testing X11/Xwayland screenshot via import (ImageMagick) ==="
DISPLAY=:0 import -window root /tmp/test_import_ss.png 2>&1 || true
ls -la /tmp/test_import_ss.png 2>/dev/null && echo "import (X11): OK" || echo "import (X11): FAILED"

echo
echo "=== 8. Testing scrot ==="
DISPLAY=:0 scrot /tmp/test_scrot_ss.png 2>&1 || true
ls -la /tmp/test_scrot_ss.png 2>/dev/null && echo "scrot: OK" || echo "scrot: FAILED"

echo
echo "=== Done. Check /tmp/test_*.png files to see which screenshots actually captured the desktop. ==="
