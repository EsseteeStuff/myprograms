#!/usr/bin/env bash
mkdir -p ~/myprograms/bin
echo 'export PATH=$PATH:$HOME/myprograms/bin:$HOME/bin' >> ~/.bashrc
. ~/.bashrc

echo "Installatie van de software dat ik zeker nodig heb."

#alleen op Debian: backup maken en contrib/non-free toevoegen aan de apt-bronnen
if [ -r /etc/os-release ]; then
    . /etc/os-release
fi

if [ "${ID:-}" = "debian" ]; then
    apt_bronnen_gewijzigd=0

    #klassiek formaat: /etc/apt/sources.list
    if [ -f /etc/apt/sources.list ]; then
        echo "Debian gedetecteerd: contrib en non-free toevoegen aan sources.list."
        sudo cp -n /etc/apt/sources.list /etc/apt/sources.list.bak
        sudo sed -i -E '/^[[:space:]]*(deb|deb-src)[[:space:]]/ { /\bcontrib\b/! s/\bmain\b/main contrib non-free/ }' /etc/apt/sources.list
        apt_bronnen_gewijzigd=1
    fi

    #deb822-formaat (Debian 13+): /etc/apt/sources.list.d/*.sources
    for f in /etc/apt/sources.list.d/*.sources; do
        [ -e "$f" ] || continue
        grep -q 'debian\.org' "$f" || continue
        echo "Debian gedetecteerd: contrib en non-free toevoegen aan $f."
        sudo cp -n "$f" "$f.bak"
        awk '
        function flush(   i, j, hasfield, hascomp, compidx, uris, val, add) {
            if (n == 0) return
            hasfield = 0
            hascomp = 0
            compidx = 0
            uris = ""
            for (i = 1; i <= n; i++) {
                if (lines[i] ~ /^[A-Za-z][A-Za-z0-9-]*[ \t]*:/) hasfield = 1
                if (lines[i] ~ /^[Uu][Rr][Ii][Ss][ \t]*:/) uris = lines[i]
                if (lines[i] ~ /^[Cc]omponents[ \t]*:/) { hascomp = 1; compidx = i }
            }
            if (hasfield && uris ~ /debian\.org/) {
                if (hascomp) {
                    val = lines[compidx]
                    sub(/^[^:]*:[ \t]*/, "", val)
                    j = compidx
                    while (j + 1 <= n && lines[j + 1] ~ /^[ \t]/) { j++; val = val " " lines[j] }
                    add = ""
                    if (val !~ /(^|[ \t])main([ \t]|$)/) add = add " main"
                    if (val !~ /(^|[ \t])contrib([ \t]|$)/) add = add " contrib"
                    if (val !~ /(^|[ \t])non-free([ \t]|$)/) add = add " non-free"
                    if (add != "") lines[j] = lines[j] add
                } else {
                    lines[++n] = "Components: main contrib non-free"
                }
            }
            for (i = 1; i <= n; i++) print lines[i]
            n = 0
            delete lines
        }
        /^[ \t]*$/ { flush(); print; next }
        { lines[++n] = $0 }
        END { flush() }
        ' "$f" | sudo tee "$f.tmp" >/dev/null
        if [ -s "$f.tmp" ]; then
            sudo chmod --reference="$f" "$f.tmp"
            sudo chown --reference="$f" "$f.tmp"
            sudo mv "$f.tmp" "$f"
            apt_bronnen_gewijzigd=1
        else
            echo "!! Kon $f niet aanpassen; bestand ongewijzigd gelaten."
            sudo rm -f "$f.tmp"
        fi
    done

    if [ "$apt_bronnen_gewijzigd" -eq 0 ]; then
        echo "Debian gedetecteerd, maar geen bronnenbestand gevonden om aan te passen; overgeslagen."
    fi
else
    echo "Geen Debian (${ID:-onbekend}): sources.list wordt niet aangepast."
fi

#architecture i386 toevoegen voor games
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
                    tk \
                    geany \
                    geany-plugins \
                    libfuse2t64 \
                    bluefish \
                    dialog \
                    ffmpeg \
                    trash-cli

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
alias rm="trash-put"
alias tl='trash-list'
alias et="trash-empty"
alias tr='trash-restore'
alias fpl='flatpak list'
alias fpi='flatpak install'
alias fpr='flatpak remove'
alias fps='flatpak search'
clear
EOF

. ~/.bash_aliases

cat > bin/install-bspwm.sh << 'EOF'
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
EOF


cat > bin/install-dwm.sh << 'EOF'
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

EOF


cat >  bin/install-docker.sh << 'EOF'
#docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker serge
EOF



cat >  bin/install-nvm << 'EOF'
#nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
sleep 2
source ~/.bashrc
nvm install --lts
nvm install 24
nvm use 24
EOF



cat >  bin/install-opencode.sh << 'EOF'
#opencode
curl -fsSL https://opencode.ai/v2/install | bash
sleep 1
source ~/.bashrc
EOF



cat >  bin/install-virt-manager.sh << 'EOF'
#virt-manager
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager -y
sudo virsh net-autostart default
sudo adduser serge libvirt
sudo adduser serge libvirt-qemu
EOF



cat >  bin/install-flatpak.sh <<'EOF'
#flatpak
sudo apt install -y flatpak flatpak-builder flatpak-xdg-utils
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
EOF



cat >  bin/install-vscode.sh <<'EOF'
#code
wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
sudo apt install -y ./code*.deb
rm -f code*.deb
EOF



cat >  bin/install-portainer.sh <<'EOF'
sudo docker pull portainer/portainer-ce:latest || error "Failed to pull latest Portainer docker image!"
sudo docker run -d -p 9500:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest --logo "https://github.com/novaspirit/pi-hosted/blob/master/images/pi-hosted-logo.png" || error "Failed to run Portainer docker image!"
EOF



cat >  bin/update-portainer.sh <<'EOF'
#update portainer
portainer_pid=`docker ps | grep portainer-ce | awk '{print $1}'`
portainer_name=`docker ps | grep portainer-ce | awk '{print $2}'`

sudo docker stop $portainer_pid || error "Failed to stop portainer!"
sudo docker rm $portainer_pid || error "Failed to remove portainer container!"
sudo docker rmi $portainer_name || error "Failed to remove/untag images from the container!"
sudo docker run -d -p 9500:9000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest --logo "https://github.com/novaspirit/pi-hosted/blob/master/images/pi-hosted-logo.png" || error "Failed to execute newer version of Portainer!"

EOF



cat >  bin/reinstall-portainer.sh <<'EOF'
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



cat >  bin/install-sudo-without-password.sh <<'EOF'
#sudo zonder password in /etc/sudoers.d
u=$(whoami)
echo "$u ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/90-$u-nopasswd >/dev/null
sudo chmod 0440 /etc/sudoers.d/90-$u-nopasswd
sudo visudo -c

EOF



chmod +x bin/*



clear

echo "Nu krijg je de kans om extra scripts te installeren."
echo "Als je kiest om het script niet te installeren"
echo "Dan kan je ze ook achteraf installeren."
echo "De scripts staat in ~/myprograms/bin."

read -n 1 -s -r -p "Druk op een toets..." </dev/tty || true



#finally: alle install-* scripts in ~/bin één voor één aanbieden
echo
echo "=== Installatiescripts gevonden in bin ==="

for f in bin/install-*; do
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

clear

echo "Het systeem kan nu opnieuw opgestart worden."
read -r -n 1 -p "Nu rebooten? [j/N] " antwoord </dev/tty || true
echo
case "$antwoord" in
    j|J|y|Y) sudo reboot ;;
    *) echo "Geen reboot. Je kan later zelf 'sudo reboot' doen." ;;
esac
