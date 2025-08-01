#!/usr/bin/env bash

if ! command -v nvim &>/dev/null; then
    yay -S --noconfirm --needed nvim luarocks tree-sitter-cli \
        cmake luachek luarocks npm go sed ripgrep composer 

    rm -rf ~/.config/nvim
    cp -R ~/.dots/config/nvim/* ~/.config/nvim/
fi
