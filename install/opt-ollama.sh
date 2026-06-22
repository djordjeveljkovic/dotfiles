#!/usr/bin/env bash
# opt --ollama: local LLM runtime. Standalone (Zed may use it, but isn't coupled).
set -euo pipefail

if ! command -v ollama &>/dev/null; then
  curl -fsSL https://ollama.com/install.sh | sh
fi

sudo systemctl enable --now ollama.service

# Pull the model Zed's config expects for edit predictions
ollama pull qwen2.5-coder:7b-base || true
