#virt-manager
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager -y
sudo virsh net-autostart default
sudo adduser serge libvirt
sudo adduser serge libvirt-qemu
clear
