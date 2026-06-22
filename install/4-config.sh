# Symlink each repo config dir into ~/.config so edits flow back to the repo.
mkdir -p ~/.config

for dir in ~/.dots/config/*/; do
  name=$(basename "$dir")
  ln -sfn "$dir" "$HOME/.config/$name"
done

# Top-level config files (vimium-options.json, etc.)
ln -sfn ~/.dots/config/vimium-options.json ~/.config/vimium-options.json

# tmux config
ln -sfn ~/.dots/default/.tmux.conf ~/.tmux.conf

# GPG keyservers (system-wide dirmngr config)
sudo mkdir -p /etc/gnupg
sudo cp ~/.dots/default/gpg/dirmngr.conf /etc/gnupg/
sudo chmod 644 /etc/gnupg/dirmngr.conf
sudo gpgconf --kill dirmngr 2>/dev/null || true
sudo gpgconf --launch dirmngr 2>/dev/null || true

# Bashrc -> single source line
echo "source ~/.dots/default/bash/rc" > ~/.bashrc

# Optional secrets.env (gitignored): sourced by default/bash/envs if present
touch ~/.config/secrets.env
chmod 600 ~/.config/secrets.env

# Common git aliases + behavior
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch main

# Identification from 2-identification.sh (or leave whatever's already set)
if [[ -n "${DEFAULT_USER_NAME//[[:space:]]/}" ]]; then
  git config --global user.name "$DEFAULT_USER_NAME"
fi
if [[ -n "${DEFAULT_USER_EMAIL//[[:space:]]/}" ]]; then
  git config --global user.email "$DEFAULT_USER_EMAIL"
fi
