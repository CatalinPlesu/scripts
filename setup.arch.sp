#!/bin/bash

sudo paru -S git

cd $HOME/.config
git init                          # Initialize Git in the current directory
git remote add origin https://github.com/CatalinPlesu/dotfiles
git fetch origin                  # Fetch repository data
git checkout -f master

sudo paru -S kitty zsh tmux fzf ripgrep fd-find ranger htop neofetch eza distrobox syncthing bat tldr-hs wl-clipboard
tldr -u

ln $HOME/.config/zsh/.zshrc $HOME/.zshrc

# Use Zsh
chsh -s $(which zsh)

# Install atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
bash atuin register

# Install keyd
# sudo rm -rf /etc/keyd
# sudo ln -s $HOME/.config/keyd/ /etc/keyd/
# 
# cd ~/Downloads/
# git clone https://github.com/rvaiya/keyd
# cd keyd
# make && sudo make install
# sudo systemctl enable --now keyd

# Syncthing
# sudo systemctl enable syncthing@catalin.service --now
