#!/bin/bash

lsblk
echo -en "\nSelect a partition to use as root (ex: /dev/sdaX): "
read part
part=$(echo "$part" | grep -o "sd.*")
part_selected=$(lsblk | grep "$part")

if [ -n "$part_selected" ]; then
	echo -e "\nYou've selected:\n$part_selected"
	echo -en "\nIs this correct? [y/n]: "
	read input
else
	echo "\nError: partition $part not found"
	exit 1
fi

case "$input" in
	y|Y|yes)	if (df | grep "$part" &>/dev/null); then
					echo -e "\nError: partition $part already mounted. Please try again"
					exit 1
				fi
	;;
	n|N|no)	echo -e "\nExiting please try again"
			exit
	;;
	*)	echo -e "\nError: invalid option. Exiting."
		exit 1
	;;
esac

echo -en "\nCreate new ext4 filesystem on: $part? [y/n]: "
read input

case "$input" in
	y|Y|yes)	mkfs.ext4 /dev/$part
	;;
	n|N|no) echo -e "\nContinuing without creating filesystem."
	;;
	*)	echo -e "\nError: invalid option. Exiting."
		exit 1
	;;
esac

echo -e "\nMounting $part at mountpoint /mnt"
mount /dev/$part /mnt

if [ "$?" -gt "0" ]; then
	echo -e "\nFailed to mount $part. Exiting..."
	exit 1
fi

echo -e "Setting up mirrorlist for UK based servers"
grep -A1 "United Kingdom" /etc/pacman.d/mirrorlist | grep -v -e "--" > /etc/pacman.d/mirrorlist.pacsave
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.original
cp /etc/pacman.d/mirrorlist.pacsave /etc/pacman.d/mirrorlist

echo -e "\nBegining Arch Linux install to /dev/$part\n"
pacstrap /mnt base base-devel grub

if [ "$?" -gt "0" ]; then
	echo -e "\nInstall failed. Exiting..."
	exit 1
fi

echo -e "\nGenerating fstab..."
genfstab -U -p /mnt >> /mnt/etc/fstab

grub_part=$(echo "$part" | grep -o "sd.")
echo -e "\nInstalling grub..."
arch-chroot /mnt grub-install --recheck /dev/$grub_part
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo -e "\nSet and generate locale"
echo "LANG=en_GB.UTF-8" > /mnt/etc/locale.conf
echo "en_GB.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo -e "\nSet keyboard to UK layout"
echo "KEYMAP=uk" > /mnt/etc/vconsole.conf

echo -e "\nSet timezone"
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

echo -en "\nEnter your desired hostname: "
read hostname
echo "$hostname" > /mnt/etc/hostname

while (true) ; do
	echo -en "\nEnter a new root password: "
	read -s password
	echo
	echo -en "Confirm root password: "
	read -s password_confirm

	if [ "$password" != "$password_confirm" ]; then
		echo -e "\nError: passwords do not match. Try again..."
	else
		printf "$password\n$password_confirm" | arch-chroot /mnt passwd &>/dev/null
		unset password password_confirm
		break
	fi
done

echo
echo -e "\nEnter a new username: "
read username
arch-chroot /mnt useradd -m -g users -G wheel,power,audio,video,storage -s /bin/bash "$username"

while (true) ; do
	echo -en "\nEnter a new password for $username: "
	read -s password
	echo
	echo -en "Confirm $username password: "
	read -s password_confirm

	if [ "$password" != "$password_confirm" ]; then
		echo -e "\nError: passwords do not match. Try again..."
	else
		printf "$password\n$password_confirm" | arch-chroot /mnt passwd "$username" &>/dev/null
		unset password password_confirm
		break
	fi
done

echo -e "\nEnabling sudo for $username..."
sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /mnt/etc/sudoers

echo -e "\nCreating xinitrc setting for $username.."
echo "exec xfce4-session" > /mnt/home/$username/.xinitrc

echo -e "\nEnabling dhcp..."
arch-chroot /mnt systemctl enable dhcpcd

echo -e "\nConfiguring Firewall..."
echo "*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
COMMIT" > /mnt/etc/iptables/iptables.rules
arch-chroot /mnt systemctl enable iptables.service

echo -e "\nInstalling additional packages"
arch-chroot /mnt pacman -S --noconfirm git screen nmap vim exfat-utils ntfs-3g intel-ucode rdesktop unrar p7zip rsync openssh etckeeper sshfs cups libmtp mtpfs android-udev android-tools python npm openvpn elinks links lynx w3m newsbeuter mutt youtube-dl ffmpeg colordiff htop dmidecode screenfetch vpnc net-tools atomicparsley unzip ddrescue testdisk gdisk gvfs-smb gvfs-nfs autofs mlocate wget dosfstools htop tk minicom clamav

echo -e "\nInstalling Xorg related stuff"
arch-chroot /mnt pacman -S --noconfirm xorg-server xorg-apps xorg-xinit xfce4 xfce4-goodies xorg-xauth

echo -e "\nInstalling X based apps"
arch-chroot /mnt pacman -S --noconfirm gparted vlc firefox audacious audacity thunderbird ttf-liberation ttf-droid ttf-dejavu ttf-ubuntu-font-family remmina xarchiver terminator keepassx2 libreoffice-fresh-en-GB x2goclient gtk3-print-backends cups-pdf gtk3-print-backends gvfs-mtp wireshark-gtk owncloud-client chromium epiphany gimp xfe meld evince alsa-utils pulseaudio pavucontrol xfce4-pulseaudio-plugin xfce4-mixer cdrtools libisoburn cdrdao dvd+rw-tools ripperx libsidplayfp libappindicator-gtk3

echo -e "\nEnabling SSHD..."
arch-chroot /mnt systemctl enable sshd.service

echo -e "\nPlaceholder for scripting the GPU"
arch-chroot /mnt lspci | grep -e VGA -e 3D
echo -en "Do you need to install GPU drivers?"
#arch-chroot /mnt pacman -S --noconfirm nvidia-340xx nvidia-340xx-utils nvidia-settings


#echo -e "\nInstall complete. Unmount system"
#umount -R /mnt
