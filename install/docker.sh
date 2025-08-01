#!/bin/bash

set -euo pipefail

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

trap 'gum style --foreground 1 "❌ Script failed at line $LINENO. Exiting."' ERR

gum style --bold --foreground 212 "🚀 Setting up Podman-only environment (no Docker)..."

# Check for yay
if ! command -v yay &>/dev/null; then
  gum style --foreground 1 "❌ 'yay' is not installed. Please install it first."
  exit 1
fi

# 1. Install podman and podman-compose
gum spin --spinner dot --title "Installing podman and podman-compose..." -- bash -c '
  yay -S --noconfirm --needed podman podman-compose >/dev/null
'

# 2. Enable and start rootless podman.service
gum spin --spinner dot --title "Enabling rootless podman.service..." -- bash -c '
  systemctl  daemon-reexec
  systemctl  enable --now podman.service >/dev/null
'

# 3. Enable and start Docker-compatible Podman socket
gum spin --spinner dot --title "Enabling Docker-compatible podman.socket..." -- bash -c '
  systemctl enable --now podman.socket >/dev/null
'

# 4. Configure container log rotation
gum spin --spinner dot --title "Configuring container log rotation..." -- bash -c '
  mkdir -p ~/.config/containers
  cat > ~/.config/containers/containers.conf <<EOF
[containers]
log_driver = "json-file"
log_size_max = 10485760
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

# 6. Pull hello-world image safely before running
gum spin --spinner dot --title "Pulling hello-world image..." -- bash -c '
  podman pull hello-world >/dev/null
'

# 7. Run a test container
gum spin --spinner dot --title "Running test container (hello-world)..." -- bash -c '
  podman run --rm hello-world
'

gum style --bold --foreground 82 "✅ Podman setup complete!"
gum style --foreground 245 "💡 Reload your shell or run:"
echo "  source ~/.bashrc"

