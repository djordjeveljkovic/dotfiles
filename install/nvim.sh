#!/usr/bin/env bash

yay -S --noconfirm --needed nvim luarocks tree-sitter-cli cmake luarocks npm go sed ripgrep composer shellcheck 

rm -rf ~/.config/nvim
cp -R ~/.dots/config/nvim/* ~/.config/nvim/
