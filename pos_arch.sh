#!/bin/bash
############### Pos install Arch Linux - Cinnamon ###############
#
# The MIT License (MIT)
#
# Copyright (c) 2018 Jacó Macena
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# Script made for automated post-installation of Arch Linux with Cinnamon +
# Grub (EFI x86_64) + Nvidia


##### Multilib e Yaourt #####
# uncomment and insert into /etc/pacman.conf

#[multilib]
#Include = /etc/pacman.d/mirrorlist

#[archlinuxfr]
#SigLevel = Never
#Server = http://repo.archlinux.fr/x86_64

usage() {
  cat <<EOF

usage: ${0##*/} [flags] [options]

  Options:

    --pass-root, -pr                     Set password ROOT
    --lang, -l				 Set language (pt_BR)
    --nmachine, -nm <name_machine>	 Set name machine
    --install, -i                        Install all packages
    --boot, -bg				 Set boot - grub (EFI - x86_64)
    --user, -su  <user> <password>       Create name to user with privilegies root/sudo
    --help, -h                           Show this is message

EOF
}

if [[ -z $1 || $1 = @(-h|--help) ]]; then
  usage
  exit $(( $# ? 0 : 1 ))
fi

pass_root(){
	passwd root
}

set_lang(){
	loadkeys br-abnt2
	echo "Keyboard configured"
	echo ""
	ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
	echo "Localtime configured"
	echo ""
	echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen
	echo "Locale configured"
	echo ""
	echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
	echo "Keymap configured"
	locale-gen
	echo "Language pt_BR installed"
}

name_machine(){

	[[ -z "$2" ]] && echo "Set name machine" && exit 1
	
	nm=$(echo "$2")

	echo "$nm" > /etc/hostname
	echo "$nm configured successfully"
}

set_install(){

	pacman -Syyyyyuuuuu

	pacman -S sudo bash-completion grub os-prober efibootmgr networkmanager net-tools intel-ucode artwiz-fonts dina-font terminus-font ttf-bitstream-vera ttf-dejavu ttf-freefont ttf-inconsolata ttf-liberation ttf-linux-libertine xorg-fonts-type1 firefox transmission-gtk xf86-input-synaptics flashplugin gimp libreoffice libreoffice-pt-BR xorg xorg-xinit alsa-lib alsa-utils alsa-firmware alsa-plugins pulseaudio-alsa pulseaudio vlc tar gzip bzip2 unzip unrar p7zip ntfs-3g wget curl epdfview intel-dri xf86-video-intel bumblebee nvidia bbswitch lib32-nvidia-utils lib32-intel-dri opencl-nvidia lib32-virtualgl linux-headers openssh cinnamon nemo-fileroller inkscape xdg-user-dirs bluez blueman bluez-utils networkmanager-pptp networkmanager-openvpn privoxy tor lynx telegram-desktop youtube-dl filezilla eog cmus libmp4v2 opusfile wavpack xterm gnome-terminal vim git gparted bleachbit jre10-openjdk gnome-system-monitor gedit wireshark-qt rkhunter gnome-calculator electrum virtualbox virtualbox-guest-iso aircrack-ng dnsutils cdrtools cifs-utils whois gdm android-tools mtr ttf-hack adobe-source-code-pro-fonts

	pacman -Rscn xorg-fonts-75dpi xorg-fonts-100dpi --no-confirm

}

boot_grub(){

	mkinitcpio -p linux

	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck /dev/sda

	grub-mkconfig -o /boot/grub/grub.cfg

}

set_user(){

    [[ -z "$2" ]] && echo "Set name user" && exit 1
    muser=$(echo "$2" | tr -d ' _-' | tr 'A-Z' 'a-z')
    
    echo "Your user: $muser:"
	useradd -m -g users -G wheel,sys,lp,network,video,optical,storage,scanner,storage,power,bumblebee -s /bin/bash "$muser"    
	echo "Set password for your user:"
	passwd "$muser"
	sed -i "s/^root ALL=(ALL) ALL$/root ALL=(ALL) ALL\n${muser} ALL=(ALL) ALL\n/" /etc/sudoers

	echo "Success: user create and included on group sudo"    
}


case "$1" in

    "--pass-root"|"-pr") pass_root;;
    "--lang"|"-l") set_lang;;
    "--nmachine"|"-nm") name_machine "$@";;
    "--install"|"-i") set_install;;
    "--boot"|"-bg") boot_grub;;
    "--user"|"-su") set_user "$@";;
    "--help"|"-h") usage ;;
    *) echo "Invalid option." && usage ;;

esac


############### Pós instalação ###############

#systemctl enable NetworkManager
#systemctl enable bumblebeed
#systemctl enable lightdm

###################
#cp /etc/X11/xinit/xinitrc /home/$USER/.xinitrc

#echo "exec cinnamon-session" >> /home/$USER/.xinitrc

#xdg-user-dirs-update

##### AUR

#i2p google-chrome beebeep teamviewer gtkpod etcher woeusb brackets masterpdfeditor crunch wd719x-firmware aic94xx-firmware paper-icon-theme
