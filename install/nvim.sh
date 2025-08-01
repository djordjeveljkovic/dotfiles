if ! command -v nvim &>/dev/null; then
  yay -S --noconfirm --needed nvim luarocks tree-sitter-cli cmake

  rm -rf ~/.config/nvim
  cp -R ~/.dots/config/nvim/* ~/.config/nvim/
fi
