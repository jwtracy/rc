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

bash() {
	cp ${_DOT_DIR}/bashrc ~/.bashrc
	cp ${_DOT_DIR}/bash_aliases ~/.bash_aliases
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
    popd
	vim +PlugInstall
}

golang() {
	pushd /usr/local/
	sudo mkdir go
	sudo wget https://golang.org/dl/go1.16.linux-amd64.tar.gz
	sudo tar -xzf go1.16.linux-amd64.tar.gz -C /usr/local
	popd
}

libs() {
	LIBRARIES="libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6"
	sudo apt install -y ${LIBRARIES}
}

deb() {
	PACKAGES="build-essential dkms git tmux curl net-tools linux-headers-$(uname -r)"
	sudo apt install -y ${PACKAGES}
}

deb
libs
# chrome
# bash
# nviminstall
# golang
# anacondainstall
# pycharminstall
