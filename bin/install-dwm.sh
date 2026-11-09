#!/usr/bin/env bash

git clone https://git.suckless.org/dwm

cd dwm

echo 'alias cdwm="vim ~/myprograms/dwm/config.h"' >> ~/.bash_aliases
echo 'alias mdwm="cd ~/myprograms/dwm; sudo make clean install; cd -";' >> ~/.bash_aliases
. ~/.bash_aliases

#install dependencies for dwm
sudo apt install -y libx11-dev libxft-dev libxinerama-dev xorg libxcb-cursor0 xwallpaper rofi alacritty

sudo make clean install

sudo cp ~/myprograms/config.h .
sudo make clean install

git clone https://git.suckless.org/dmenu
cd dmenu
sudo make clean install


git clone https://git.suckless.org/st
cd ../st
sudo make clean install

touch -f ~/.xinitrc

echo 'xrandr -s 2560x1440' > ~/.xinitrc
echo 'xwallpaper --zoom ~/myprograms/tomb-raider.jpg &' >> ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc
cp -r ~/myprograms/rofi ~/.config/

cd ~/
clear
