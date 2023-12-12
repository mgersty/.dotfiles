#!/bin/bash
#
function main(){
    echo "Installing apps from debian package manager"

    apt update && apt upgrade -y
    echo "Checking for sudo program"
    if ! command -v sudo &> /dev/null
    then
        echo "Sudo is not present.  Installing now"
        apt install -y --no-install-recommends sudo
    fi
    sudo apt install -y --no-install-recommends \
        sudo \
        ca-certificates \
        build-essential \
        gnupg \
        gzip \
        curl \
        unzip \
        wget

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

    sudo apt update

    sudo apt install -y --no-install-recommends \
        zsh \
        jq \
        ncdu \
        htop \
        tmux \
        tree \
        neovim \
        git \
        openjdk-8-jdk \
        scala \
        maven \
        gh \
        docker-ce \
        docker-ce-cli \
        containerd.io


    sudo groupadd docker
    sudo usermod -aG docker $USER

    echo "Installing oh my zsh shell"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y

    echo "Installing aws cli"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
        && unzip awscliv2.zip \
        && sudo ./aws/install

#     echo "Installing Homebrew"
#     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#     echo "Installing Pyenv"
#     brew install pyenv
#     brew install glab
}

main
