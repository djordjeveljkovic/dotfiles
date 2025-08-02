# Copy over configs
cp -R ~/.dots/config ~/.config 
sudo cp ~/.dots/default/.tmux.conf ~/.tmux.conf

# Setup GPG configuration with multiple keyservers for better reliability
sudo mkdir -p /etc/gnupg
sudo cp ~/.dots/default/gpg/dirmngr.conf /etc/gnupg/
sudo chmod 644 /etc/gnupg/dirmngr.conf
sudo gpgconf --kill dirmngr || true
sudo gpgconf --launch dirmngr || true

# Use default bashrc
echo "source ~/.dots/default/bash/rc" >~/.bashrc

# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch main

# Set identification from install inputs
if [[ -n "${DEFAULT_USER_NAME//[[:space:]]/}" ]]; then
  git config --global user.name "$DEFAULT_USER_NAME"
fi

if [[ -n "${DEFAULT_USER_EMAIL//[[:space:]]/}" ]]; then
  git config --global user.email "$DEFAULT_USER_EMAIL"
fi
