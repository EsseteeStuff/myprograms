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
		    curl \
		    mc \
		    eza \
		    mdadm \
            vim \
            htop \
            btop \
		    tk

chmod +x ~/myprograms/*.sh

cat >> install-dwm.sh << 'EOF'
#!/bin/sh

git clone https://git.suckless.org/dwm

cd dwm

echo 'alias cdwm="vim ~/myprograms/dwm/config.h"' >> ~/.bash_aliases
echo 'alias mdwm="cd ~/myprograms/dwm; sudo make clean install; cd -";' >> ~/.bash_aliases
. ~/.bash_aliases

#install dependencies for dwm
sudo apt install -y libx11-dev libxft-dev libxinerama-dev xorg libxcb-cursor0 lxterminal lxpolkit xwallpaper rofi

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

echo 'xrandr -s 1920x1080' > ~/.xinitrc
echo 'xwallpaper --zoom ~/myprograms/tomb-raider.jpg &' >> ~/.xinitrc
echo "exec dwm" >> ~/.xinitrc
cp -r ~/myprograms/rofi ~/.config/

cd ~/

echo "type startx to start a native dwm"

sleep 5
EOF

cat >> ~/bin/install-docker.sh << 'EOF'
#docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker serge
EOF

cat >> ~/bin/install-nvm << 'EOF'
#nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.bashrc
nvm install --lts
nvm install 24
nvm use 24
EOF

cat >> ~/bin/install-opencode.sh << 'EOF'
#opencode
curl -fsSL https://opencode.ai/v2/install | bash
. ~/.bashrc
EOF

cat >> ~/bin/install-virt-manager.sh << 'EOF'
#virt-manager
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager -y
sudo virsh net-autostart default
sudo adduser serge libvirt
sudo adduser serge libvirt-qemu
EOF

cat >> ~/bin/install-flatpak.sh <<'EOF'
#flatpak
sudo apt install -y flatpak flatpak-builder flatpak-xdg-utils
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
EOF

cat >> ~/bin/install-vscode.sh <<'EOF'
#code
wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
sudo apt install -y ./code*.deb
rm -f code*.deb
EOF


cat >> ~/bin/install-portainer.sh <<'EOF'
sudo docker pull portainer/portainer-ce:latest || error "Failed to pull latest Portainer docker image!"
sudo docker run -d -p 9500:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest --logo "https://github.com/novaspirit/pi-hosted/blob/master/images/pi-hosted-logo.png" || error "Failed to run Portainer docker image!"
EOF

cat >> ~/bin/update-portainer.sh <<'EOF'
#update portainer
portainer_pid=`docker ps | grep portainer-ce | awk '{print $1}'`
portainer_name=`docker ps | grep portainer-ce | awk '{print $2}'`

sudo docker stop $portainer_pid || error "Failed to stop portainer!"
sudo docker rm $portainer_pid || error "Failed to remove portainer container!"
sudo docker rmi $portainer_name || error "Failed to remove/untag images from the container!"
sudo docker run -d -p 9500:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest --logo "https://github.com/novaspirit/pi-hosted/blob/master/images/pi-hosted-logo.png" || error "Failed to execute newer version of Portainer!"
EOF

cat >> ~/bin/reinstall-portainer.sh <<'EOF'
#reinstall portainer
portainer_pid=`docker ps | grep portainer-ce | awk '{print $1}'`
portainer_name=`docker ps | grep portainer-ce | awk '{print $2}'`

echo Removing the old version of Portainer
sudo docker stop $portainer_pid || warning "Failed to stop portainer!"
sudo docker rm $portainer_pid || warning "Failed to remove portainer container!"
sudo docker rmi $portainer_name || warning "Failed to remove/untag images from the container!"

echo Pruning unused volume.  If asked answer yes.
sudo docker volume prune

echo now doing a fresh install of portainer
sudo docker run -d -p 9500:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest --logo "https://github.com/novaspirit/pi-hosted/blob/master/images/pi-hosted-logo.png" || error "Failed to execute newer version of Portainer!"
EOF

cat >> ~/bin/install-sudo-without-password.sh <<'EOF'
#sudo zonder password in /etc/sudoers.d
u=$(whoami)
echo "$u ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/90-$u-nopasswd >/dev/null
sudo chmod 0440 /etc/sudoers.d/90-$u-nopasswd
sudo visudo -c
EOF

chmod +x ~/bin/*

cat >> ~/.bash_aliases <<'EOF'
alias apin='sudo apt install'
alias purge='sudo apt remove'
alias fix='sudo apt install --fix-broken'
alias weg='sudo apt autoremove'
alias zoek='apt search'
alias up='sudo apt update && sudo apt upgrade -y'
alias ssha='eval $(ssh-agent) && ssh-add ~/.ssh/terryn_serge'
alias sshgit='eval $(ssh-agent) && ssh-add ~/.ssh/myGitKey'
alias ls='eza -lag'
EOF

. ~/.bash_aliases




#finally: alle install-* scripts in ~/bin één voor één aanbieden
echo
echo "=== Installatiescripts gevonden in ~/bin ==="

for f in "$HOME"/bin/install-*; do
    # geen enkel bestand gevonden? dan bestaat de glob letterlijk
    [ -e "$f" ] || continue

    echo
    echo "Script: $f"
    printf 'Wil je dit script uitvoeren? [j/N] '
    antwoord=""
    read -r antwoord </dev/tty || antwoord=""

    case "$antwoord" in
        j|J|ja|Ja|JA|y|Y|yes|Yes|YES)
            echo "-> Uitvoeren van $f"
            if command -v bash >/dev/null 2>&1; then
                bash "$f"
            else
                sh "$f"
            fi
            status=$?
            if [ "$status" -ne 0 ]; then
                echo "!! $f is gestopt met exitcode $status"
            fi
            ;;
        *)
            echo "-> Overgeslagen: $f"
            ;;
    esac
done

echo
echo "Alle installatiescripts zijn behandeld. Systeem wordt nu herstart na 10 sec..."
echo "Alle scripts staan in je $HOME/bin"
echo "Installeer sommige scripts die je later nodig kan hebben."
echo "Als je de dwm windowmanger wil installeren, run het bestand dwm-install.sh in ~/myprograms..."
sleep 10
sudo reboot
