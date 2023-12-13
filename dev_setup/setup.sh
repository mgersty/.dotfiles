#!/bin/bash

export NEOVIM_VERSION='0.9.4'
export DELTA_VERION='0.16.5'

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
    wget \
    vim

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
    git \
    openjdk-8-jdk \
    scala \
    maven \
    gh \
    docker-ce \
    docker-ce-cli \
    containerd.io


sudo groupadd docker
sudo usermod -aG docker "$USER"

echo "Installing oh my zsh shell"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y

echo "Installing aws cli"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install

wget "https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_${DELTA_VERSION}_amd64.deb"
sudo dpkg -i git-delta_${DELTA_VERION}_amd64.deb

wget "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux64.tar.gz"
sudo tar -xvzf nvim-linux64.tar.gz -C /usr/local
sudo ln -s /usr/local/nvim-linux64/bin/nvim /usr/local/bin/nvim


