#!/bin/sh
mkdir -p ~/bin

#backup maken van sources.list
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

#toevoegen van contrib en non-free in sources.list en architecture i386 toevoegen voor games
sudo sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
sudo dpkg --add-architecture i386
sudo apt update

sudo apt install -y build-essential \
		    ansible \
		    python3-dev \
		    python3-pip \
		    python3-venv \
		    python3-toml \
		    python3-wheel \
		    python3-setuptools \
		    git \
		    curl \
		    mc \
		    eza \
		    mdadm \
            vim \
            htop \
            btop \
		    tk

git clone https://github.com/EsseteeStuff/myprograms.git
cd myprograms
chmod +x *
./startdeel2.sh

