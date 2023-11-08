#!/bin/bash




function main(){
    echo "Installing apps from debian package manager"
    
    apt update && apt upgrade -y
    apt install sudo -y

    sudo apt install \
        ncdu \
        build-essential \
        htop \
        tmux \
        tree \
        curl \
        unzip \
        wget \
        neovim \
        git \
        maven -y
    
    echo "Installing oh my zsh shell"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y
    
    echo "Installing aws cli"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
        && unzip awscliv2.zip \
        && sudo ./aws/install

    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


    echo "Installing Pyenv"
    brew install pyenv
}


main
