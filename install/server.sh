#!/usr/bin/env bash
# Server profile: headless. No GUI, no sway, no autologin.
set -euo pipefail

# DB client libraries for container dev
paru -S --noconfirm --needed mariadb-libs postgresql-libs

# Headless niceties
paru -S --noconfirm --needed htop

echo "Server profile installed. No GUI configured."
