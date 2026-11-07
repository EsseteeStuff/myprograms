#!/bin/sh
git clone https://git.suckless.org/dwm

cd dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/st
git clone https://git.suckless.org/surf

#install dependencies for dwm
sudo apt install -y libx11-dev libxft-dev libxinerama-dev xorg libxcb-cursor0

sudo make install clean

cd dmenu
sudo make install clean

 cd ../st
sudo make install clean

 cd ../surf
sudo make install clean

touch -f ~/.xinitrc

echo "exec dwm" > ~/.xinitrc

cd ~/

echo "type startx to start dwm"
sleep 5
