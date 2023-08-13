#!/bin/zsh

# Scuffed script to install various dependencies for my system
# Probably needs some better error handling and maybe a log output

installrust() {
  echo "Installing Rustup..."
  if ! [ -x "$(command -v "rustup")" ]; then
    sudo pacman -S rustup
    echo "Finished installing Rustup."
  else 
    echo "Rustup already installed."
  fi

  echo "Installing Rust..."
  if ! [ -x "$(command -v "rustc")" ] && [ -x "$(command -v "rustup")" ]; then
    rustup default stable
    echo "Finished installing Rust"
  elif ! [ -x "$(command -v "rustup")" ]; then
    echo "Rustup not installed, cannot install Rust"
    exit 1
  else
    echo "Rust already installed"
  fi
}

installnode() {
  echo "Installing nvm..."
  if [ ! -d "${HOME}/.config/nvm/.git" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash >/dev/null 2>&1
    source ~/.zprofile
    echo "Finished installing nvm"
  else
    echo "nvm already installed."
  fi

  echo "Installing Node..."
  if ! which node > /dev/null && [ -d "${HOME}/.config/nvm/.git" ]; then
    source ~/.config/nvm/nvm.sh
    nvm install node
    echo "Finished installing Node"
  elif [ ! -d "${HOME}/.config/nvm/.git" ]; then
    echo "nvm not installed, cannot install Node"
    exit 1
  else
    echo "Node already installed"
  fi
}

installrust
installnode
# Only node needs the restart - maybe fix later
echo "Please restart the shell to start using the programs"
