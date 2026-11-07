#!/bin/sh

git clone https://git.suckless.org/dwm

cd dwm

echo 'alias cdwm="vim ~/myprograms/dwm/config.h"' >> ~/.bash_aliases
echo 'alias mdwm="cd ~/myprograms/dwm; sudo make clean install; cd -";' >> ~/.bash_aliases
. ~/.bash_aliases

#install dependencies for dwm
sudo apt install -y libx11-dev libxft-dev libxinerama-dev xorg libxcb-cursor0 lxterminal lxpolkit

mkdir -p patches
cd patches
wget https://dwm.suckless.org/patches/vanitygaps/dwm-vanitygaps-20190508-6.2.diff
cd ../
patch -i patches/dwm-vanitygaps-20190508-6.2.diff

cp config.def.h config.h
sed -i 's/#define MODKEY Mod1Mask/#define MODKEY Mod4Mask/g' config.h
sed -i 's/static const char *termcmd[]  = { "st", NULL };/static const char *termcmd[]  = { "lxterminal", NULL };/g' config.h
sed -i 's/{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },/{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },/g' config.h
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
echo "dwmblocks &" >> ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc

git clone https://github.com/tonybanters/dwmblocks
cd dwmblocks
sudo make clean install

cd ~/

echo "type startx to start a native dwm"

sleep 5
