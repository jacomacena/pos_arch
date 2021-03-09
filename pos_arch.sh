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
# Script made for automated post-installation of Arch Linux with Cinnamon/i3 +
# Grub (EFI x86_64) + Nvidia

usage() {
  cat <<EOF

usage: ${0##*/} [flags] [options]

  Options:
  
    --install, -i			 Install all packages (I3)
    --remove, -u			 Remove all packages (keeps the base)
    --help, -h				 Show this is message
EOF
}

if [[ -z $1 || $1 = @(-h|--help) ]]; then
  usage
  exit $(( $# ? 0 : 1 ))
fi

set_remove(){
	pacman -R $(comm -23 <(pacman -Qq | sort) <((for i in $(pacman -Qqg base); do pactree -ul "$i"; done) | sort -u))
}

set_pacman(){

	echo "[multilib]" >> /etc/pacman.conf
	echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
	
	echo "[arcanisrepo]" >> /etc/pacman.conf
	echo "Server = https://repo.arcanis.me/\$arch" >> /etc/pacman.conf
	
	echo "Pacman configured..."
	sleep 2

}

pass_root(){
	clear
	echo "pass root:"
	passwd root
	sleep 2
}

set_lang(){
	clear
	loadkeys br-abnt2
	echo "Keyboard configured..."
	echo ""
	ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
	timedatectl set-ntp true
	hwclock --systohc
	echo "Localtime configured..."
	echo ""
	echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen
	echo "Locale configured..."
	echo ""
	echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
	echo "Keymap configured..."
	cp xorg/00-keyboard.conf /etc/X11/xorg.conf.d/
	cp xorg/20-intel.conf /etc/X11/xorg.conf.d/
	cp xorg/40-touchpad.conf /etc/X11/xorg.conf.d/
	cp lang/keyboard /etc/default/
	cp lang/locale /etc/default/
	locale-gen
	echo "Language pt_BR installed..."
	sleep 2
}

name_machine(){
	clear
	
	echo "set name machine:"
	
	read nm
	
	[[ -z "$nm" ]] && echo "Set name machine" && exit 1
	
	nm1=$(echo "$nm")

	echo "$nm1" > /etc/hostname
	echo "$nm1 configured successfully"
	sleep 2
}

boot_grub(){

	clear
	
	echo "GRUB:"

	mkinitcpio -p linux

	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck /dev/sda

	grub-mkconfig -o /boot/grub/grub.cfg
	
	echo "grub configured successfully"
	
	sleep 2

}

set_user(){

	clear

    	[[ -z "$2" ]] && echo "Set name user"
	read u
    	muser=$(echo "$u" | tr -d ' _-' | tr 'A-Z' 'a-z')
    
    echo "Your user: $muser:"
	useradd -m -g users -G wheel,sys,lp,network,video,optical,scanner,storage,power,bumblebee,log,games,disk,vboxusers,wireshark -s /bin/bash "$muser"    
	echo "Set password for your user:"
	passwd "$muser"
	sed -i "s/^root ALL=(ALL) ALL$/root ALL=(ALL) ALL\n${muser} ALL=(ALL) ALL\n/" /etc/sudoers

	cp /etc/X11/xinit/xinitrc /home/$muser/.xinitrc
	echo "exec i3" >> /home/$muser/.xinitrc
	
	cp -r conf/pictures/* /home/$muser/Pictures/

	echo "Success: user create and included on group sudo"
	sleep 2
}

set_services(){
	clear
	echo "set services..."
	systemctl enable NetworkManager
	systemctl enable bumblebeed
	systemctl enable slim
	echo "configured services"
}

set_pkgs(){
	clear
	echo "Install Base..."
	sleep 2
	pacman -S linux linux-{headers,firmware} --noconfirm
	pacman -S sudo zsh bash-completion grub os-prober efibootmgr net-tools intel-ucode lynx tar gzip bzip2 unzip unrar p7zip --noconfirm
	pacman -S xorg xorg-xinit alsa-{lib,utils,firmware,plugins} pulseaudio-alsa pulseaudio --noconfirm
	pacman -S xterm vim git rkhunter mtr yaourt aircrack-ng dnsutils ntfs-3g wget curl openssh whois cifs-utils --noconfirm

	clear
	echo "Install Fonts..."
	sleep 2
	pacman -S ttf-{bitstream-vera,dejavu,inconsolata,freefont,roboto,font-awesome,liberation,linux-libertine} --noconfirm
	pacman -S dina-font terminus-font adobe-source-code-pro-fonts xorg-fonts-type1 --noconfirm

	clear
	echo "Install Video..."
	sleep 2
	pacman -S xf86-video-intel bumblebee nvidia bbswitch opencl-nvidia --noconfirm
	#pacman -S lib32-nvidia-430xx-utils nvidia-430xx-utils lib32-primus --noconfirm

	clear
	echo "Install WM..."
	sleep 2
	pacman -S i3 dmenu compton slim rofi exo libmp4v2 cmus gvfs network-manager-applet --noconfirm
	pacman -S playerctl pamixer light feh pcmanfm xarchiver networkmanager file-roller terminator --noconfirm
	pacman -S opusfile wavpack bluez blueman bluez-utils cdrtools pavucontrol numlockx scrot nitrogen cpio arj lrzip lz4 unrar lzip --noconfirm

	clear
	echo "Install Apps..."
	sleep 2
	pacman -S gparted ghostscript inkscape bleachbit jre-openjdk jdk-openjdk gedit wireshark-qt firefox transmission-gtk gimp --noconfirm
	pacman -S libreoffice libreoffice-pt-BR virtualbox virtualbox-guest-iso telegram-desktop neofetch --noconfirm
	pacman -S android-tools code pidgin arc-gtk-theme pepper-flash lxappearance gsimplecal gwenview vlc epdfview --noconfirm
}

set_install_i3(){

	set_pacman
	
	pacman -Syyyyyuuuuu

	set_pkgs
	
	pass_root
	
	set_lang
	
	name_machine
	
	boot_grub
	
	set_user
	
	set_services
	
	clear
	echo "To finalize the settings, reboot the system and install via yaourt the following packages:"
	echo "polybar nerd-fonts-complete wd719x-firmware aic94xx-firmware paper-icon-theme optimus-manager google-chrome i3lock-fancy-git"
	sleep 10
	
}

case "$1" in

    "--install"|"-i") set_install_i3;;
    "--remove"|"-u") set_remove;;
    "--help"|"-h") usage ;;
    *) echo "Invalid option." && usage ;;

esac
