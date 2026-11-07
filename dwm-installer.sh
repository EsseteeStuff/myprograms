#!/bin/sh

git clone https://git.suckless.org/dwm

cd dwm

echo 'alias cdwm="vim ~/myprograms/dwm/config.h"' >> ~/.bash_aliases
echo 'alias mdwm="cd ~/myprograms/dwm; sudo make clean install; cd -";' >> ~/.bash_aliases
. ~/.bash_aliases

#install dependencies for dwm
sudo apt install -y libx11-dev libxft-dev libxinerama-dev xorg libxcb-cursor0 lxterminal lxpolkit xwallpaper

sudo make install clean

git clone https://git.suckless.org/dmenu
cd dmenu
sudo make install clean


git clone https://git.suckless.org/st
cd ../st
sudo make install clean

touch -f ~/.xinitrc

echo 'xrandr -s 1920x1080' > ~/.xinitrc
echo 'xwallpaper --zoom ~/myprograms/tomb-raider.jpg &' >> ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc

cd ~/

echo "type startx to start a native dwm"

sleep 5
