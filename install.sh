#!/bin/bash


_DOT_DIR="./dot"

sudo apt update

source ${_DOT_DIR}/bashrc

chrome() {
	pushd $(mktemp -d)
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt install ./google-chrome-stable_current_amd64.deb
	popd
}

anacondainstall() {
	pushd $(mktemp -d)
	wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
	chmod +x Anaconda3-2020.11-Linux-x86_64.sh
	sudo ./Anaconda3-2020.11-Linux-x86_64.sh -bf -p ${CONDA}
	popd
}

pycharminstall() {
	pushd $(mktemp -d)
	wget https://download-cf.jetbrains.com/python/pycharm-professional-2020.3.3.tar.gz
	sudo tar -xzf pycharm-professional-2020.3.3.tar.gz -C /usr/local
    sudo mv /usr/local/pycharm-* ${PYCHARM}
	popd
}

bashinstall() {
	cp ${_DOT_DIR}/bashrc ~/.bashrc
	cp ${_DOT_DIR}/bash_aliases ~/.bash_aliases
}

dockerinstall() {
    # from https://g3doc.corp.google.com/cloud/containers/g3doc/glinux-docker/install.md?cl=head#installation
    # Remove old docker-* packages (if installed)
    sudo apt remove docker-engine docker-runc docker-containerd
    
    sudo glinux-add-repo docker-ce-"$(lsb_release -cs)"
    sudo apt update
    sudo apt install docker-ce docker-compose
    sudo systemctl stop docker
    sudo ip link set docker0 down
    sudo ip link del docker0
    
    # Update Docker daemon config file:
    # * move Docker's storage location for more space.
    # * avoid conflicts between the Docker bridge and Corp IPs
    # * turn on the debug mode, if you don't want that you could set that to false
    cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "data-root": "/usr/local/google/docker",
  "bip": "192.168.9.1/24",
  "default-address-pools": [
    {
      "base": "192.168.11.0/22",
      "size": 24
    }
  ],
  "storage-driver": "overlay2",
  "debug": true,
  "registry-mirrors": ["https://mirror.gcr.io"]
}
EOF
    
    sudo systemctl start docker
    # Group already exists on new gLinux
    sudo addgroup docker
    sudo adduser $USER docker
    # Authenticate the gcloud installation:
    gcloud auth login # (requires Python 2.7)
    gcloud auth application-default login
    # Configure docker to use docker-credential-gcloud for GCR registries:
    gcloud auth configure-docker
}

kubectlinstall() {
    pushd $(mktemp -d)
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl completion bash >> ~/.bashrc
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    sudo chmod o+x $(which helm)
    helm completion bash >> ~/.bashrc
    popd
}

githubinstall() {
    type -p curl >/dev/null || sudo apt install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
        && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
    gh completion -s bash >> ~/.bashrc
}

nvminstall() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
    nvm install --latest-npm
    npm completion >> ~/.bashrc
    echo "node" > ~/.nvmrc
}

nviminstall() {
	cp ${_DOT_DIR}/vimrc ~/.vimrc
	sudo apt install neovim
	mkdir -p ~/.config/nvim
	ln -sf ~/.vimrc ~/.config/nvim/init.vim
    pushd $(mktemp -d)
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo ./nvim.appimage
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    popd
	nvim +PlugInstall
    ln -sf /bin/nvim /etc/alternatives/vi
    ln -sf /bin/nvim /etc/alternatives/vim
}

golang() {
	pushd /usr/local/
	sudo mkdir go
	sudo wget https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
	sudo tar -xzf go1.19.2.linux-amd64.tar.gz -C /usr/local
	popd
}

libs() {
	LIBRARIES="libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6"
	sudo apt install -y ${LIBRARIES}
}

deb() {
	PACKAGES="build-essential ca-certificates dkms git tmux curl net-tools linux-headers-$(uname -r) code jq google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin"
	sudo apt install -y ${PACKAGES}
}

deb
# libs
# chrome
# bashinstall
# nviminstall
# kubectlinstall
# nvminstall
# golang
# anacondainstall
# pycharminstall
# githubinstall
# dockerinstall
