#!/bin/bash
set -e

echo "=== Setting up ydotoold systemd service ==="
sudo tee /etc/systemd/system/ydotoold.service > /dev/null <<'EOF'
[Unit]
Description=ydotool daemon
After=local-fs.target

[Service]
ExecStartPre=-/bin/rm -f /tmp/.ydotool_socket
ExecStart=/usr/bin/ydotoold
ExecStartPost=/bin/bash -c 'for i in $(seq 1 20); do [ -e /tmp/.ydotool_socket ] && break; sleep 0.1; done; chmod 666 /tmp/.ydotool_socket'
Restart=always

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now ydotoold
sleep 1
sudo systemctl status ydotoold --no-pager | head -10
ls -la /tmp/.ydotool_socket

echo
echo "=== Testing ydotool input (moves mouse 5px, should be harmless) ==="
ydotool mousemove -- 5 5 && echo "ydotool mouse move: OK" || echo "ydotool mouse move: FAILED"

echo
echo "=== Testing screenshot via GNOME D-Bus Shell.Screenshot ==="
gdbus call --session --dest org.gnome.Shell.Screenshot --object-path /org/gnome/Shell/Screenshot --method org.gnome.Shell.Screenshot.Screenshot true false /tmp/test_shell_ss.png 2>&1 || true
ls -la /tmp/test_shell_ss.png 2>/dev/null && echo "Shell.Screenshot: OK" || echo "Shell.Screenshot: FAILED/DENIED"

echo
echo "=== Testing X11/Xwayland screenshot via import (ImageMagick) ==="
DISPLAY=:0 import -window root /tmp/test_import_ss.png 2>&1 || true
ls -la /tmp/test_import_ss.png 2>/dev/null && echo "import (X11): OK" || echo "import (X11): FAILED"

echo
echo "=== Testing scrot ==="
DISPLAY=:0 scrot /tmp/test_scrot_ss.png 2>&1 || true
ls -la /tmp/test_scrot_ss.png 2>/dev/null && echo "scrot: OK" || echo "scrot: FAILED"

echo
echo "=== Done ==="
