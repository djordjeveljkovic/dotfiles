#!/usr/bin/env bash

set -euo pipefail

APP_DIR="$HOME/.dots"
THEME_NAME="bgrt"
IMAGE_SOURCE="$APP_DIR/plymouth_image.png"
IMAGE_TARGET="/usr/share/plymouth/themes/spinner/watermark.png"
PLYMOUTH_INSTALLED=$(command -v plymouth)

timestamp=$(date +"%Y%m%d%H%M%S")

# Install plymouth if not present
if [[ -z "$PLYMOUTH_INSTALLED" ]]; then
    yay -S --noconfirm --needed plymouth
fi

echo "🔧 Configuring Plymouth..."

# Backup and modify mkinitcpio.conf
if grep -q "^HOOKS=" /etc/mkinitcpio.conf && ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    echo "🛡️  Backing up /etc/mkinitcpio.conf..."
    sudo cp /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak.${timestamp}"

    if grep -q "base systemd" /etc/mkinitcpio.conf; then
        sudo sed -i '/^HOOKS=/s/base systemd/base systemd plymouth/' /etc/mkinitcpio.conf
    elif grep -q "base udev" /etc/mkinitcpio.conf; then
        sudo sed -i '/^HOOKS=/s/base udev/base udev plymouth/' /etc/mkinitcpio.conf
    else
        echo "⚠️  Could not find base systemd or base udev in HOOKS"
    fi

    echo "📦 Rebuilding initramfs..."
    sudo mkinitcpio -P
fi

# Kernel bootloader detection and config
if [ -d "/boot/loader/entries" ]; then
    echo "🖋️  Detected systemd-boot"
    for entry in /boot/loader/entries/*.conf; do
        [[ "$(basename "$entry")" == *fallback* ]] && continue

        if ! grep -q "splash" "$entry"; then
            sudo sed -i '/^options/ s/$/ splash quiet/' "$entry"
        fi
    done

elif [ -f "/etc/default/grub" ]; then
    echo "🖋️  Detected GRUB"
    sudo cp /etc/default/grub "/etc/default/grub.bak.${timestamp}"
    sudo cp "$APP_DIR/grub" /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg

elif [ -d "/etc/cmdline.d" ]; then
    echo "🖋️  Detected UKI (cmdline.d)"
    defo_file="/etc/cmdline.d/defo.conf"
    [[ -f "$defo_file" ]] || sudo touch "$defo_file"
    grep -q splash "$defo_file" || echo "splash" | sudo tee -a "$defo_file"
    grep -q quiet "$defo_file" || echo "quiet" | sudo tee -a "$defo_file"

elif [ -f "/etc/kernel/cmdline" ]; then
    echo "🖋️  Detected UKI (/etc/kernel/cmdline)"
    sudo cp /etc/kernel/cmdline "/etc/kernel/cmdline.bak.${timestamp}"
    cmdline=$(< /etc/kernel/cmdline)
    [[ "$cmdline" != *splash* ]] && cmdline="$cmdline splash"
    [[ "$cmdline" != *quiet* ]] && cmdline="$cmdline quiet"
    echo "$cmdline" | xargs | sudo tee /etc/kernel/cmdline > /dev/null

else
    echo -e "\n⚠️  Bootloader not recognized. Please add 'splash quiet' manually to kernel parameters.\n"
fi

# Set Plymouth theme and image
echo "🖼️  Setting Plymouth theme and custom image..."
sudo cp "$IMAGE_SOURCE" "$IMAGE_TARGET"
sudo plymouth-set-default-theme -R "$THEME_NAME"

echo "✅ Plymouth setup complete with '$THEME_NAME' theme and updated image."

