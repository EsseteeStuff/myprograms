#!/bin/sg
git clone https://git.suckless.org/dwm

cd dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/st
git clone https://git.suckless.org/surf

#install dependencies for dwm
sudo apt install -y libx11-dev libxft-dev libxinerama-dev xorg libxcb-cursor0

make install clean

cd dmenu
 make install clean

 cd ../st
 make install clean

 cd ../surf
 make install clean

 touch -f ~/.xinitrc

 echo "exec dwm" > ~/.xinitrc

 cd ~/

 echo "type startx to start dwm"
 sleep 5
 