#sudo zonder password in /etc/sudoers.d
u=$(whoami)
echo "$u ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/90-$u-nopasswd >/dev/null
sudo chmod 0440 /etc/sudoers.d/90-$u-nopasswd
sudo visudo -c
clear
