#!/usr/bin/env bash
# Rootless Podman as a Docker-compatible runtime.
# Merged from the old install/docker.sh; podman was also previously in development.sh.
set -euo pipefail

paru -S --noconfirm --needed podman podman-compose

# Enable rootless podman.service (user)
systemctl --user enable --now podman.service 2>/dev/null || true

# Docker-compatible socket so `docker` CLI / lazydocker / docker-compose work
sudo systemctl enable --now podman.socket 2>/dev/null || true

# Container log rotation
mkdir -p ~/.config/containers
cat > ~/.config/containers/containers.conf <<EOF
[containers]
log_driver = "json-file"
log_size_max = 10485760
log_file = 5
EOF

# DOCKER_HOST is exported by default/bash/envs; nothing to do here.
# lazydocker is bound to SUPER+D — install it too.
paru -S --noconfirm --needed lazydocker
