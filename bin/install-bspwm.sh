#!/usr/bin/env bash
sudo apt update
sudo apt install bspwm sxhkd rofi picom polybar dunst feh
mkdir -p ~/.config/bspwm ~/.config/sxhkd
install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/bspwm/bspwmrc
echo 'xrandr -s 2560x1440' > ~/.xinitrc
echo 'xwallpaper --zoom ~/myprograms/tomb-raider.jpg &' >> ~/.xinitrc
echo "sxhkd &" >> ~/.xinitrc
echo 'exec bspwm' >> ~/.xinitrc
cp -r ~/myprograms/rofi ~/.config/
