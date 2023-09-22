# Simple scripted install for Archlinux

Not for production use.

## TODO:

1. verify GPG signature of install ISO
2. loadkeys
3. check internet connectivity - or output wifi setup command
4. partition disk
    1. create GPT/UEFI partition
    2. create root partition
    3. create encrypted home partition
    4. create swap partition
5. sync hardware clock
6. microcode package
7. grub or systemd?
8. do some post install items during install?
9. script GPU install?
10. create duplicate script for EFI based system?
11. install wayland
12. pull down post install script and save locally