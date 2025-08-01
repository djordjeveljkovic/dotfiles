#!/bin/bash

set -e

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

gum style --bold --foreground 212 "🚀 Setting up Podman-only environment (no Docker)..."

# 1. Install podman and podman-compose
gum spin --spinner dot --title "Installing podman and podman-compose..." -- \
  yay -S --noconfirm --needed podman podman-compose

# 2. Enable and start rootless podman.service
gum spin --spinner dot --title "Enabling rootless podman.service..." -- \
  systemctl --user enable --now podman.service

# 3. Enable and start Docker-compatible Podman socket
gum spin --spinner dot --title "Enabling Docker-compatible podman.socket..." -- \
  systemctl enable --now podman.socket

# 4. Configure container log rotation
gum spin --spinner dot --title "Configuring container log rotation..." -- bash -c '
  mkdir -p ~/.config/containers
  cat > ~/.config/containers/containers.conf <<EOF
[containers]
log_driver = "json-file"
log_size_max = "10m"
log_file = 5
EOF
'

# 5. Set DOCKER_HOST environment variable
gum spin --spinner dot --title "Configuring DOCKER_HOST for CLI compatibility..." -- bash -c '
  export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
  if ! grep -q "DOCKER_HOST=unix://\\\$XDG_RUNTIME_DIR/podman/podman.sock" ~/.bashrc; then
    echo "export DOCKER_HOST=unix://\$XDG_RUNTIME_DIR/podman/podman.sock" >> ~/.bashrc
  fi
'

# 6. Run a test container
gum spin --spinner dot --title "Running test container (hello-world)..." -- \
  podman run --rm hello-world

gum style --bold --foreground 82 "✅ Podman setup complete! Reload your shell or run: source ~/.bashrc"

