#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." 
    exit 1
fi

# need to set this before running the script
device="/dev/sdX"

echo -e "o\np\nn\np\n1\n\n+200M\nt\nc\nn\np\n2\n\n" | fdisk "$device"
echo -e "w" | fdisk "$device"

mkfs.vfat "${device}1"
mkdir boot
mount "${device}1" boot

# Create and mount the ext4 filesystem
mkfs.ext4 "${device}2"
mkdir root
mount "${device}2" root

wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-armv7-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-armv7-latest.tar.gz -C root
sync

mv root/boot/* boot
umount boot root
echo "Installation complete."
