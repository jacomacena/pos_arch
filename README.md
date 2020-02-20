# Script Post Installation of Arch Linux with I3 + Nvidia + Grub (EFI - x86_64)
-----------------------------------------------------------------------------------------------------

Script that will facilitate the post installation of Arch Linux with I3 graphical environment.

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
- insertion of 'multilib' and 'arcanisrepo' mirrolists
- root password setting
- set language 'pt-BR' on keyboard and system language
- zoneinfo 'America / Sao_Paulo'
- set machine name
- install useful programs
- configure Grub
- enter a user (with sudo permissions)
- enable post installation services (NetworkManager, slim, bumblebee - nvidia)
