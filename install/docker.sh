#!/bin/bash

set -euo pipefail

# === Style helpers ===
log() { gum style --foreground "$1" "$2"; }

# === Dependency check ===
for cmd in ssh-keygen curl gum; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Required command '$cmd' is missing. Please install: $cmd"
    exit 1
  fi
done

# === Detect package manager ===
install_pkg() {
  if command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm "$1"
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y "$1"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$1"
  else
    log 1 "❌ Unsupported package manager. Please install '$1' manually."
    exit 1
  fi
}

# === Install openssh if missing ===
if ! command -v sshd &>/dev/null; then
  log 3 "📦 Installing OpenSSH..."
  install_pkg openssh || { log 1 "❌ Failed to install OpenSSH"; exit 1; }
fi

# === Enable and start sshd ===
log 2 "🔧 Enabling and starting SSH server..."
sudo systemctl enable --now sshd || { log 1 "❌ Failed to start sshd"; exit 1; }

# === Ask for key name using gum ===
KEY_NAME=$(gum input --placeholder "Enter SSH key name (e.g. id_ed25519_secure)")
[[ -z "$KEY_NAME" ]] && log 1 "❌ SSH key name is required." && exit 1
KEY_PATH="$HOME/.ssh/$KEY_NAME"

# === Generate SSH key if it doesn't exist ===
if [[ -f "$KEY_PATH" ]]; then
  log 3 "🔑 SSH key already exists: $KEY_PATH"
else
  ssh-keygen -t ed25519 -f "$KEY_PATH" -C "$USER@$(hostname)" -N "" || {
    log 1 "❌ SSH key generation failed"; exit 1;
  }
  log 2 "✅ SSH key generated: $KEY_PATH"
fi

# === Configure .ssh and authorized_keys ===
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

PUB_KEY=$(< "${KEY_PATH}.pub")

if ! grep -qxF "$PUB_KEY" "$HOME/.ssh/authorized_keys"; then
  echo "$PUB_KEY" >> "$HOME/.ssh/authorized_keys"
  log 2 "✅ Public key added to authorized_keys"
else
  log 3 "🔎 Public key already exists in authorized_keys"
fi

# === Harden sshd_config ===
log 2 "🔒 Hardening SSH configuration..."

SSHD_CONFIG="/etc/ssh/sshd_config"
sudo cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak" # Backup

sudo sed -i \
  -e 's/^#\?\s*PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^#\?\s*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
  -e 's/^#\?\s*PermitEmptyPasswords.*/PermitEmptyPasswords no/' \
  -e 's/^#\?\s*UsePAM.*/UsePAM no/' \
  -e 's/^#\?\s*PermitRootLogin.*/PermitRootLogin no/' \
  "$SSHD_CONFIG" || {
    log 1 "❌ Failed to modify $SSHD_CONFIG"
    exit 1
  }

# === Optionally restrict login to current user ===
if gum confirm "Restrict SSH login to current user only ('$USER')?"; then
  if grep -q "^AllowUsers" "$SSHD_CONFIG"; then
    sudo sed -i "s/^AllowUsers.*/AllowUsers $USER/" "$SSHD_CONFIG"
  else
    echo "AllowUsers $USER" | sudo tee -a "$SSHD_CONFIG" >/dev/null
  fi
  log 2 "✅ SSH access restricted to: $USER"
fi

# === Restart sshd ===
sudo systemctl restart sshd || { log 1 "❌ Failed to restart sshd"; exit 1; }
log 2 "🔁 SSH service restarted"

# === Configure firewall if available ===
if command -v ufw &>/dev/null; then
  log 2 "🔐 Configuring UFW for SSH..."
  sudo ufw allow OpenSSH
  sudo ufw enable || log 3 "⚠️ UFW already enabled or failed"
elif command -v firewall-cmd &>/dev/null; then
  log 2 "🔐 Configuring firewalld for SSH..."
  sudo firewall-cmd --permanent --add-service=ssh
  sudo firewall-cmd --reload
else
  log 3 "⚠️ No firewall tool detected. SSH might be blocked externally."
fi

# === Final message ===
log 2 "✅ SSH setup complete!"
log 3 "💡 You can now connect using:"
echo -e "\n  ssh -i $KEY_PATH $USER@<your-ip>\n"

