# Install bluetooth controls
paru -S --noconfirm --needed bluetui

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service
