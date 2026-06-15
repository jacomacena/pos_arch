# Script Post Installation of Arch Linux for Dell Inspiron 15 3520 (P112F)
-----------------------------------------------------------------------------------------------------

Script that will facilitate the post installation of Arch Linux with I3/BSPWM
graphical environment, Intel integrated graphics and Grub (EFI - x86_64).

After command "arch-chroot /mnt /bin/bash"

Steps:

\# pacman -S git

\# git clone https://github.com/jacomacena/pos_arch.git

\# cd pos_arch

\# run chmod +x pos_arch.sh

After changing/adding the execute mode in the pos_arch.sh file (chmod +x pos_arch.sh) simply execute the following forms:

\# ./pos_arch.sh -i (for I3 installation)

\# ./pos_arch.sh --help (will display how to use)

Changes that the script provides:
- insertion of 'multilib' mirrorlist
- root password setting
- set language 'pt-BR' on keyboard and system language
- zoneinfo 'America / Sao_Paulo'
- set machine name
- install useful programs and Dell laptop packages
- install Intel graphics, media acceleration, PipeWire and SOF firmware
- configure Grub
- enter a user (with sudo permissions)
- enable post installation services (NetworkManager, Bluetooth, thermald, TLP, acpid, slim, fstrim)
