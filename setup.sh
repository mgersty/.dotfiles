#!/usr/bin/env bash

set -e

export NEOVIM_VERSION='0.9.4'
export DELTA_VERSION='0.16.5'
export NEEDRESTART_MODE='a'

#In case the environment this script is running in does not have sudo installed
if ! command -v sudo &> /dev/null
then
    echo "Sudo is not present. Please make sure sudo is installed on this distro before excuting this script"
    exit 1
fi

WORK_DIR=$(mktemp -d)
cd "${WORK_DIR}"
echo "Switching to ${PWD} as current working directory"

sudo apt update && apt upgrade -y --no-install-recommends

########################################
########################################
#Installing essential dev enviroment utils
########################################
########################################
sudo apt install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    gnupg \
    gzip \
    curl \
    unzip \
    wget \
    sssd-tools \
    vim

########################################
########################################
#Setting up external sources for apt
########################################
########################################

# Setup Docker source list entry for apt
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Setup github cli source list entry
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

sudo apt update

########################################
########################################
# Installing local developer tools and sdks
########################################
########################################
sudo apt install -y --no-install-recommends \
    zsh \
    jq \
    ncdu \
    htop \
    tmux \
    tree \
    git \
    openjdk-8-jdk \
    openjdk-11-jdk \
    openjdk-17-jdk \
    scala \
    maven \
    gh \
    ripgrep \
    exa \
    fzf \
    bat

sudo sss_override user-add ${USER} --shell /bin/zsh
sudo systemctl restart sssd

echo "Installing nvm"
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

if ! command -v aws &> /dev/null
then
    echo "Installing aws cli"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
        && unzip awscliv2.zip \
        && sudo ./aws/install --update
fi

wget "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
sudo dpkg -i git-delta_${DELTA_VERSION}_amd64.deb


########################################
########################################
# Installing Docker
########################################
########################################
sudo apt install -y --no-install-recommends \
    docker-ce \
    docker-ce-cli \
    containerd.io \
&& sudo groupadd docker \
&& sudo usermod -aG docker "$USER"


########################################
########################################
# Setting up Neovim
########################################
########################################
wget "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux64.tar.gz"
sudo tar -xvzf nvim-linux64.tar.gz -C /usr/local
sudo ln -s /usr/local/nvim-linux64/bin/nvim /usr/local/bin/nvim

git clone https://github.com/mgersty/.dotfiles.git ${HOME}/.dotfiles
export DOT_FILES_LOCATION="${HOME}/.dotfiles"

mkdir -p "${HOME}"/.config \
&& ln -s "${DOT_FILES_LOCATION}"/nvim "${HOME}/.config/nvim" \
&& ln -s "${DOT_FILES_LOCATION}"/.tmux.conf "${HOME}/.tmux.conf" \
&& ln -s "${DOT_FILES_LOCATION}"/.gitconfig "${HOME}/.gitconfig"


########################################
########################################
# Setting up Oh My ZShell
########################################
########################################
zshell_home_dir="$HOME/.oh-my-zsh"

if [ -d "$zshell_home_dir" ]; then
     echo "Oh My ZShell alreadly installed"
     # uninstall_oh_my_zsh
else
     echo "Installing oh my zsh shell"
     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -y
fi
