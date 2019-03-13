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
  
    --install-cinnamon, -ic              Install all packages (Cinnamon)
    --install-i3, -ii3			 Install all packages (I3)
    --help, -h                           Show this is message

EOF
}

if [[ -z $1 || $1 = @(-h|--help) ]]; then
  usage
  exit $(( $# ? 0 : 1 ))
fi

set_pacman(){

	echo "[multilib]" >> /etc/pacman.conf
	echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
	
	echo "[arcanisrepo]" >> /etc/pacman.conf
	echo "Server = https://repo.arcanis.me/repo/\$arch" >> /etc/pacman.conf
	
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
	echo "Localtime configured..."
	echo ""
	echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen
	echo "Locale configured..."
	echo ""
	echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
	echo "Keymap configured..."
	cp 00-keyboard.conf /etc/X11/xorg.conf.d/
	cp 20-intel.conf /etc/X11/xorg.conf.d/
	cp 40-touchpad.conf /etc/X11/xorg.conf.d/
	cp keyboard /etc/default/
	cp locale /etc/default/
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

    	[[ -z "$2" ]] && echo "Set name user" && exit 1
	read u
    	muser=$(echo "$u" | tr -d ' _-' | tr 'A-Z' 'a-z')
    
    echo "Your user: $muser:"
	useradd -m -g users -G wheel,sys,lp,network,video,optical,storage,scanner,storage,power,bumblebee,log,games,disk,vboxusers,wireshark -s /bin/bash "$muser"    
	echo "Set password for your user:"
	passwd "$muser"
	sed -i "s/^root ALL=(ALL) ALL$/root ALL=(ALL) ALL\n${muser} ALL=(ALL) ALL\n/" /etc/sudoers

	echo "Success: user create and included on group sudo"   
	sleep 2
}

set_services(){
	clear
	echo "set services..."
	systemctl enable NetworkManager
	systemctl enable bumblebeed
	systemctl enable gdm
	echo "configured services"
}

set_install_cin(){

	set_pacman
	
	pacman -Syyyyyuuuuu
	
	pacman -S sudo bash-completion grub os-prober efibootmgr ttf-roboto networkmanager net-tools intel-ucode artwiz-fonts dina-font terminus-font ttf-bitstream-vera ttf-dejavu ttf-freefont ttf-inconsolata ttf-liberation ttf-linux-libertine xorg-fonts-type1 firefox transmission-gtk xf86-input-synaptics flashplugin gimp libreoffice libreoffice-pt-BR xorg xorg-xinit alsa-lib alsa-utils alsa-firmware alsa-plugins pulseaudio-alsa pulseaudio vlc tar gzip bzip2 unzip unrar p7zip ntfs-3g wget curl epdfview intel-dri xf86-video-intel bumblebee nvidia bbswitch lib32-nvidia-utils lib32-intel-dri opencl-nvidia lib32-virtualgl linux-headers openssh cinnamon nemo-fileroller inkscape xdg-user-dirs bluez blueman bluez-utils networkmanager-pptp networkmanager-openvpn privoxy tor lynx telegram-desktop youtube-dl filezilla eog cmus libmp4v2 opusfile wavpack xterm gnome-terminal vim git gparted scrot bleachbit jre10-openjdk gnome-system-monitor gedit wireshark-qt rkhunter gnome-calculator electrum virtualbox virtualbox-guest-iso aircrack-ng dnsutils cdrtools cifs-utils whois gdm android-tools mtr ttf-hack adobe-source-code-pro-fonts atom yaourt pidgin
	
	yaourt -S polybar nomachine nerd-fonts-complete etcher woeusb crunch wd719x-firmware aic94xx-firmware paper-icon-theme optimus-manager google-chrome
	
	pacman -Rscn xorg-fonts-75dpi xorg-fonts-100dpi
	
	pass_root
	
	set_lang
	
	name_machine
	
	boot_grub
	
	set_user
	
	set_services

}

set_install_i3(){

	set_pacman
	
	pacman -Syyyyyuuuuu

	pacman -S sudo bash-completion grub os-prober efibootmgr compton ttf-roboto thunar-volman networkmanager net-tools intel-ucode artwiz-fonts dina-font terminus-font ttf-bitstream-vera ttf-dejavu ttf-freefont ttf-inconsolata ttf-liberation ttf-linux-libertine xorg-fonts-type1 firefox transmission-gtk gimp libreoffice libreoffice-pt-BR xorg xorg-xinit alsa-lib alsa-utils alsa-firmware alsa-plugins pulseaudio-alsa pulseaudio vlc tar gzip bzip2 unzip unrar p7zip ntfs-3g wget curl epdfview intel-dri xf86-video-intel bumblebee nvidia bbswitch opencl-nvidia linux-headers openssh i3 thunar file-roller inkscape bluez blueman bluez-utils lynx telegram-desktop eog cmus libmp4v2 opusfile wavpack xterm terminator vim git gparted bleachbit jre10-openjdk gedit wireshark-qt rkhunter virtualbox virtualbox-guest-iso aircrack-ng dnsutils cdrtools cifs-utils whois gdm android-tools mtr adobe-source-code-pro-fonts atom yaourt dmenu gvfs numlockx scrot rofi exo playerctl pamixer light feh pidgin lxappearance gsimplecal ttf-font-awesome gucharmap ntp
	
	yaourt -S polybar nomachine networkmanager-dmenu-git nerd-fonts-complete etcher woeusb crunch wd719x-firmware aic94xx-firmware paper-icon-theme optimus-manager google-chrome i3lock-fancy-git

	pacman -Rscn xorg-fonts-75dpi xorg-fonts-100dpi
	
	pass_root
	
	set_lang
	
	name_machine
	
	boot_grub
	
	set_user
	
	set_services

}

case "$1" in

    "--install-cinnamon"|"-ic") set_install_cin;;
    "--install-i3"|"-ii3") set_install_i3;;
    "--help"|"-h") usage ;;
    *) echo "Invalid option." && usage ;;

esac
