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

installeww() {
  echo "Installing eww..."
  if [ ! -d "${HOME}/.local/src/eww/target/release" ]; then
    mkdir ~/.local/src
    cd ~/.local/src
    git clone https://github.com/elkowar/eww
    cd eww
    cargo build --release --no-default-features --features=wayland
    cd target/release
    chmod +x ./eww
    cd ~
    echo "Finished installing eww"
  else
    echo "eww already installed"
  fi
}

installrust
installnode
installeww

# Only node needs the restart - maybe fix later
echo "Please restart the shell to start using the programs"
