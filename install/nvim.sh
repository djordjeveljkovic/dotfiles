#!/usr/bin/env bash

paru -S --noconfirm --needed nvim luarocks tree-sitter-cli cmake luarocks npm go sed ripgrep composer shellcheck 

rm -rf ~/.config/nvim
cp -r ~/.dots/config/nvim ~/.config/
