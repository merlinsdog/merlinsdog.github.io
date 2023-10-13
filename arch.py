import os
import subprocess

# Python version of the arch.sh script

def run_command(command):
    result = subprocess.run(command, shell=True)
    return result.returncode

def main():
    os.system('lsblk')
    part = input("\nSelect a partition to use as the root partition (ex: /dev/sdaX): ")
    part = os.path.basename(part)
    part_selected = subprocess.getoutput(f'lsblk | grep {part}')

    if part_selected:
        print(f"\nYou've selected:\n{part_selected}")
        input_response = input("\nIs this correct? [y/n]: ")
    else:
        print(f"\nError: partition {part} not found")
        exit(1)

    if input_response.lower() in ['y', 'yes']:
        if subprocess.getoutput(f'df | grep {part}'):
            print(f"\nError: partition {part} already mounted. Please try again")
            exit(1)
    elif input_response.lower() in ['n', 'no']:
        print("\nExiting please try again")
        exit()
    else:
        print("\nError: invalid option. Exiting.")
        exit(1)

    input_response = input(f"\nCreate new ext4 filesystem on: {part}? [y/n]: ")

    if input_response.lower() in ['y', 'yes']:
        run_command(f'mkfs.ext4 /dev/{part}')
    elif input_response.lower() in ['n', 'no']:
        print("\nContinuing without creating filesystem.")
    else:
        print("\nError: invalid option. Exiting.")
        exit(1)

    print(f"\nMounting {part} at mountpoint /mnt")
    if run_command(f'mount /dev/{part} /mnt') > 0:
        print(f"\nFailed to mount {part}. Exiting...")
        exit(1)

    print("Setting up mirrorlist for UK based servers")
    run_command('reflector -c GB --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist')

    print(f"\nBeginning Arch Linux install to /dev/{part}\n")
    if run_command('pacstrap -K /mnt base base-devel grub linux linux-firmware') > 0:
        print("\nInstall failed. Exiting...")
        exit(1)

    print("\nGenerating fstab...")
    run_command('genfstab -U -p /mnt >> /mnt/etc/fstab')

    grub_part = os.path.basename(part)
    print("\nInstalling grub...")
    run_command(f'arch-chroot /mnt grub-install --target=i386-pc /dev/{grub_part}')
    run_command('arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg')

    print("\nSet and generate locale")
    with open('/mnt/etc/locale.conf', 'w') as locale_file:
        locale_file.write("LANG=en_GB.UTF-8\n")
    with open('/mnt/etc/locale.gen', 'a') as locale_file:
        locale_file.write("en_GB.UTF-8 UTF-8\n")
    run_command('arch-chroot /mnt locale-gen')

    print("\nSet keyboard to UK layout")
    with open('/mnt/etc/vconsole.conf', 'w') as vconsole_file:
        vconsole_file.write("KEYMAP=uk\n")

    print("\nSet timezone")
    run_command('arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime')

    hostname = input("\nEnter your desired hostname: ")
    with open('/mnt/etc/hostname', 'w') as hostname_file:
        hostname_file.write(hostname)

    while True:
        password = input("\nEnter a new root password: ")
        password_confirm = input("Confirm root password: ")
        if password != password_confirm:
            print("\nError: passwords do not match. Try again...")
        else:
            with subprocess.Popen(['arch-chroot', '/mnt', 'passwd'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as passwd_process:
                passwd_input = f"{password}\n{password_confirm}\n"
                passwd_process.communicate(input=passwd_input.encode())
            break

    username = input("\nEnter a new username: ")
    run_command(f'arch-chroot /mnt useradd -m -g users -G wheel,power,audio,video,storage -s /bin/bash {username}')

    while True:
        password = input(f"\nEnter a new password for {username}: ")
        password_confirm = input(f"Confirm {username} password: ")
        if password != password_confirm:
            print("\nError: passwords do not match. Try again...")
        else:
            with subprocess.Popen(['arch-chroot', '/mnt', 'passwd', username], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as passwd_process:
                passwd_input = f"{password}\n{password_confirm}\n"
                passwd_process.communicate(input=passwd_input.encode())
            break

    print(f"\nEnabling sudo for {username}...")
    with open('/mnt/etc/sudoers', 'r') as sudoers_file:
        sudoers_data = sudoers_file.read()
    sudoers_data = sudoers_data.replace('# %wheel ALL=(ALL) ALL', '%wheel ALL=(ALL) ALL')
    with open('/mnt/etc/sudoers', 'w') as sudoers_file:
        sudoers_file.write(sudoers_data)

    print(f"\nCreating xinitrc setting for {username}..")
    with open(f'/mnt/home/{username}/.xinitrc', 'w') as xinitrc_file:
        xinitrc_file.write("exec xfce4-session\n")

    print("\nEnabling dhcp...")
    run_command('arch-chroot /mnt systemctl enable dhcpcd')

    print("\nConfiguring Firewall...")
    iptables_rules = """*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -i lo -j ACCEPT
COMMIT"""
    with open('/mnt/etc/iptables/iptables.rules', 'w') as iptables_file:
        iptables_file.write(iptables_rules)
    run_command('arch-chroot /mnt systemctl enable iptables.service')

    print("\nPlaceholder for scripting the GPU")
    gpu_info = subprocess.getoutput('arch-chroot /mnt lspci | grep -e VGA -e 3D')
    print(f"The following GPUs have been found. Be sure to install the correct driver:\n{gpu_info}")

    print("Install complete. Unmount system")
    run_command('umount -R /mnt')

if __name__ == "__main__":
    main()
