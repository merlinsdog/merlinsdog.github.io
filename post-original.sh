#!/bin/bash

pacman -S --noconfirm iptables nmap openssh sshfs gparted rdesktop python wget git screen

pacman -S --noconfirm exfat-utils ntfs-3g intel-ucode unrar p7zip rsync unzip ddrescue testdisk gvfs-smb gvfs-nfs mlocate dosfstools tk minicom clamav

pacman -S --noconfirm libmtp mtpfs android-udev android-tools youtube-dl ffmpeg dmidecode atomicparsley 

pacman -S --noconfirm vlc audacious audacity remmina xarchiver gvfs-mtp gimp meld alsa-utils pulseaudio cdrtools libisoburn cdrdao dvd+rw-tools 

pacman -S --noconfirm firefox vivaldi chromium epiphany links elinks lynx w3m

pacman -S --noconfirm terminator xterm zsh zsh-completions bash-completion gnome-terminal vim

pacman -S --noconfirm libreoffice-fresh-en-gb evince

pacman -S --noconfirm xed htop filezilla thunderbird mutt newsboat

pacman -S --noconfirm xorg-server xorg-apps xorg-xinit xorg-xauth cinnamon metacity gnome-shell mate-icon-theme mate-themes archlinux-wallpaper

pacman -S --noconfirm nemo-share nemo-terminal nemo-python nemo-fileroller

pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-host-dkms

pacman -S --noconfirm ttf-bitstream-vera ttf-liberation ttf-droid ttf-dejavu

pacman -S --noconfirm terragrunt ansible terraform ansible-lint

pacman -S --noconfirm networkmanager-vpnc networkmanager-pptp net-tools vpnc

pacman -S --noconfirm mate-icon-theme mate-themes

pacman -S --noconfirm gnome-calculator gnome-keyring gnome-backgrounds gnome-themes-extra flameshot

pacman -S --noconfirm cups cups-pdf hplip

pacman -S --noconfirm chrony

pacman -S --noconfirm dconf-editor

pacman -S --noconfirm usbutils

pacman -S --noconfirm docker

pacman -S --noconfirm openvpn networkmanager-openvpn

echo "optional install xf86-video-intel vscodium protonbridge signal-desktop"
echo "add exec cinnamon-session to .xinitrc"
