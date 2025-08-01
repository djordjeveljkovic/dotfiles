#!/bin/bash
# Setup seamless auto-login for Hyprland using UWSM and a custom VT manager

# Install UWSM
yay -S --needed --noconfirm uwsm

# Create seamless-login.c
cat <<'EOF' >/tmp/seamless-login.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <linux/vt.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) return fprintf(stderr, "Usage: %s <session_command>\n", argv[0]), 1;

    int vt = open("/dev/tty1", O_RDWR);
    if (vt < 0) return perror("open"), 1;

    if (ioctl(vt, VT_ACTIVATE, 1) || ioctl(vt, VT_WAITACTIVE, 1) || ioctl(vt, KDSETMODE, KD_GRAPHICS))
        return perror("ioctl"), close(vt), 1;

    write(vt, "\33[H\33[2J", 6);
    close(vt);

    if (getenv("HOME")) chdir(getenv("HOME"));
    execvp(argv[1], &argv[1]);
    perror("execvp");
    return 1;
}
EOF

# Compile and move binary
gcc -O2 -o /usr/local/bin/seamless-login /tmp/seamless-login.c && \
sudo chmod +x /usr/local/bin/seamless-login && \
rm /tmp/seamless-login.c

# Create systemd service
sudo tee /etc/systemd/system/minimal-seamless-login.service >/dev/null <<EOF
[Unit]
Description=Minimal Seamless Auto-Login
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service plymouth-quit.service systemd-logind.service
PartOf=graphical.target

[Service]
Type=simple
ExecStart=/usr/local/bin/seamless-login uwsm start -- hyprland.desktop
Restart=always
RestartSec=2
User=$USER
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
StandardInput=tty
StandardOutput=journal
StandardError=journal+console
PAMName=login

[Install]
WantedBy=graphical.target
EOF

# Reload and enable service
sudo systemctl daemon-reload
sudo systemctl enable minimal-seamless-login.service
sudo systemctl disable getty@tty1.service

