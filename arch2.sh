#!/bin/bash

# lsblk

# echo -en "\nSelect a disk to install Arch Linux (ex: /dev/sdX): "
# read disk

# if [ ! -e "$disk" ]; then
#     echo -e "\nError: Disk $disk not found"
#     exit 1
# fi

disk=/dev/sda

echo "Selected disk: $disk\n\nIs this the correct disk layout? [y/n]: "
read confirmation



parted --script $disk \
    mklabel gpt \
    mkpart primary fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart primary linux-swap 513MiB 1024MiB \
    mkpart primary ext4 1+100%
    

mkfs.fat -F32 ${disk}1
mkswap ${disk}2
mkfs.ext4 -L ROOT ${disk}3

mount ${disk}3 /mnt
mount --mkdir ${disk}1 /mnt/boot
swapon ${disk}2


echo "Setting up mirrorlist for UK based servers"
reflector -c GB --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "Begining Arch Linux install to ${disk}3"
pacstrap -K /mnt base base-devel grub linux linux-headers linux-firmware efibootmgr networkmanager dhcpcd

if [ "$?" -gt "0" ]; then
	echo "Installation failed. Exiting..."
	exit 1
fi

echo "Generating fstab..."
genfstab -U -p /mnt >> /mnt/etc/fstab

echo "Installing grub..."
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "Set and generate locale"
echo "LANG=en_GB.UTF-8" > /mnt/etc/locale.conf
echo "en_GB.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo "Setting keyboard to UK layout"
echo "KEYMAP=uk" > /mnt/etc/vconsole.conf

echo "Setting timezone to London"
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

echo "Enter hostname: "
read hostname
echo "$hostname" > /mnt/etc/hostname

while (true) ; do
	echo "Enter a new root password: "
	read -s password
	echo
	echo "Confirm root password: "
	read -s password_confirm

	if [ "$password" != "$password_confirm" ]; then
		echo -e "Error: passwords do not match. Try again..."
	else
		printf "$password\n$password_confirm" | arch-chroot /mnt passwd &>/dev/null
		unset password password_confirm
		break
	fi
done

echo
echo "Enter a new user name: "
read username
arch-chroot /mnt useradd -m -g users -G wheel,power,audio,video,storage -s /bin/bash "$username"

while (true) ; do
	echo "Enter a new password for $username: "
	read -s password
	echo
	echo "Confirm $username password: "
	read -s password_confirm

	if [ "$password" != "$password_confirm" ]; then
		echo "Error: passwords do not match. Try again..."
	else
		printf "$password\n$password_confirm" | arch-chroot /mnt passwd "$username" &>/dev/null
		unset password password_confirm
		break
	fi
done

echo "Enabling sudo for $username..."
sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /mnt/etc/sudoers

echo "Creating xinitrc setting for $username.."
echo "exec xfce4-session" > /mnt/home/$username/.xinitrc

echo "Enabling Network Manager ..."
arch-chroot /mnt systemctl enable NetworkManager

echo "Configuring Firewall..."
echo "*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -i lo -j ACCEPT
COMMIT" > /mnt/etc/iptables/iptables.rules
arch-chroot /mnt systemctl enable iptables.service


gpu_info=$(arch-chroot /mnt lspci | grep -e VGA -e 3D)

# Check if the GPU information is available
if [ -n "$gpu_info" ]; then
    echo "Detected GPU: $gpu_info"

    # Install the appropriate driver based on the detected GPU
    if [[ "$gpu_info" == *"NVIDIA"* ]]; then
        echo "Installing NVIDIA driver..."
        arch-chroot /mnt pacman -S --noconfirm nvidia
    elif [[ "$gpu_info" == *"AMD"* ]]; then
        echo "Installing AMD driver..."
        arch-chroot /mnt pacman -S --noconfirm xf86-video-amdgpu
    elif [[ "$gpu_info" == *"Intel"* ]]; then
        echo "Installing Intel driver..."
        arch-chroot /mnt pacman -S --noconfirm xf86-video-intel
    else
        echo "Unsupported GPU. Please install the appropriate driver manually."
    fi
else
    echo "No GPU information found. Please check your hardware configuration."
fi



echo "Install complete. Unmount system"
umount -R /mnt
