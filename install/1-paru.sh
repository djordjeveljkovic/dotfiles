sudo pacman -S --needed --noconfirm base-devel

if ! command -v paru &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/paru-bin.git
  cd paru-bin
  makepkg -si --noconfirm
  cd -
  rm -rf paru-bin
  cd ~

  # Add fun and color to the pacman installer
  sudo sed -i '/^\[options\]/a Color\nILoveCandy' /etc/pacman.conf
fi
