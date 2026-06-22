#!/usr/bin/env bash
paru -S --noconfirm --needed nvim luarocks tree-sitter-cli cmake npm go ripgrep shellcheck

# Symlink so edits flow back to the repo (replaces the old cp -r)
ln -sfn ~/.dots/config/nvim ~/.config/nvim
