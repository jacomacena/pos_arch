#!/usr/bin/env bash
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
# Script made for automated post-installation of Arch Linux on Dell Inspiron
# with i3/bspwm, Grub (EFI x86_64) and Intel graphics.

set -Eeuo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACMAN_REPOS=(
  "[multilib]|Include = /etc/pacman.d/mirrorlist"
)
BASE_GROUPS=(base)
USER_GROUPS=(wheel sys lp network video optical scanner storage power log games disk vboxusers docker)
SERVICES=(NetworkManager bluetooth thermald tlp acpid slim fstrim.timer docker)

usage() {
  cat <<EOF
usage: ${0##*/} [flags]

Options:
  -i, --install    Install and configure the post-install environment
  -u, --remove     Remove non-base packages
  -h, --help       Show this help
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '\n==> %s\n' "$*"
}

need_root() {
  [[ ${EUID} -eq 0 ]] || die "run this script as root."
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

confirm() {
  local answer
  read -r -p "$1 [y/N] " answer
  [[ ${answer,,} == y || ${answer,,} == yes ]]
}

append_pacman_repo() {
  local header="${1%%|*}"
  local include="${1#*|}"

  if grep -Fxq "$header" /etc/pacman.conf; then
    return
  fi

  {
    printf '\n%s\n' "$header"
    printf '%s\n' "$include"
  } >> /etc/pacman.conf
}

install_packages() {
  pacman -S --needed --noconfirm "$@"
}

copy_file() {
  local source=$1
  local target=$2

  install -Dm644 "$SCRIPT_DIR/$source" "$target"
}

set_remove() {
  need_root
  need_command pacman
  need_command pactree

  confirm "Remove all packages except the base dependency tree?" || exit 0

  mapfile -t keep_packages < <(
    for group in "${BASE_GROUPS[@]}"; do
      pacman -Qqg "$group"
    done | while read -r pkg; do
      pactree -ul "$pkg"
    done | sort -u
  )

  mapfile -t remove_packages < <(comm -23 <(pacman -Qq | sort) <(printf '%s\n' "${keep_packages[@]}" | sort -u))

  ((${#remove_packages[@]})) || die "no removable packages found."
  pacman -Rns "${remove_packages[@]}"
}

set_pacman() {
  need_root
  need_command pacman

  log "Configuring pacman repositories"
  for repo in "${PACMAN_REPOS[@]}"; do
    append_pacman_repo "$repo"
  done

  pacman -Syu --noconfirm
}

pass_root() {
  need_root

  log "Set root password"
  passwd root
}

set_lang() {
  need_root

  log "Configuring locale, timezone and keyboard"
  loadkeys br-abnt2
  ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  timedatectl set-ntp true
  hwclock --systohc

  grep -q '^pt_BR.UTF-8 UTF-8$' /etc/locale.gen || printf 'pt_BR.UTF-8 UTF-8\n' >> /etc/locale.gen
  locale-gen

  printf 'LANG=pt_BR.UTF-8\n' > /etc/locale.conf
  printf 'KEYMAP=br-abnt2\n' > /etc/vconsole.conf

  copy_file xorg/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
  copy_file xorg/40-touchpad.conf /etc/X11/xorg.conf.d/40-touchpad.conf
}

name_machine() {
  local hostname

  need_root
  log "Set machine name"
  read -r -p "Hostname: " hostname

  [[ $hostname =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$ ]] || die "invalid hostname."

  printf '%s\n' "$hostname" > /etc/hostname
  cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${hostname}.localdomain ${hostname}
EOF
}

boot_grub() {
  need_root

  log "Configuring GRUB"
  mkinitcpio -p linux
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck
  grub-mkconfig -o /boot/grub/grub.cfg
}

set_user() {
  local username wm pictures_dir

  need_root
  log "Create user"
  read -r -p "Username: " username
  username="$(printf '%s' "$username" | tr -d ' _-' | tr '[:upper:]' '[:lower:]')"

  [[ $username =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || die "invalid username."
  id "$username" >/dev/null 2>&1 || useradd -m -g users -G "$(IFS=,; printf '%s' "${USER_GROUPS[*]}")" -s /bin/bash "$username"

  passwd "$username"

  if ! grep -Eq "^${username}[[:space:]]+ALL=\\(ALL(:ALL)?\\)[[:space:]]+ALL$" /etc/sudoers; then
    printf '%s ALL=(ALL:ALL) ALL\n' "$username" > "/etc/sudoers.d/$username"
    chmod 0440 "/etc/sudoers.d/$username"
  fi

  read -r -p "Window manager (i3 or bspwm): " wm
  [[ $wm == i3 || $wm == bspwm ]] || die "unsupported window manager: $wm."

  install -Dm644 /etc/X11/xinit/xinitrc "/home/$username/.xinitrc"
  printf '\nexec %s\n' "$wm" >> "/home/$username/.xinitrc"

  pictures_dir="/home/$username/Pictures"
  install -d -m755 "$pictures_dir"
  cp -n "$SCRIPT_DIR"/conf/pictures/* "$pictures_dir"/
  chown -R "$username:users" "/home/$username/.xinitrc" "$pictures_dir"
}

set_services() {
  local service

  need_root
  log "Enabling services"
  for service in "${SERVICES[@]}"; do
    systemctl enable "$service"
  done
}

set_pkgs() {
  need_root
  need_command pacman

  local base_pkgs=(
    linux linux-headers linux-firmware sudo zsh bash-completion grub os-prober
    efibootmgr net-tools intel-ucode lynx tar gzip bzip2 unzip unrar p7zip
  )
  local xorg_pkgs=(
    xorg xorg-xinit xorg-server xterm xf86-input-libinput
    alsa-lib alsa-utils alsa-firmware alsa-plugins sof-firmware
    pipewire pipewire-alsa pipewire-pulse wireplumber
  )
  local cli_pkgs=(
    vim git rkhunter mtr aircrack-ng dnsutils ntfs-3g wget curl openssh
    whois cifs-utils
  )
  local font_pkgs=(
    ttf-bitstream-vera ttf-dejavu ttf-inconsolata ttf-roboto
    ttf-font-awesome ttf-liberation ttf-linux-libertine dina-font terminus-font
    adobe-source-code-pro-fonts xorg-fonts-type1
  )
  local laptop_pkgs=(
    thermald tlp tlp-rdw acpi acpid upower brightnessctl fwupd
  )
  local intel_video_pkgs=(
    mesa mesa-utils vulkan-intel intel-media-driver libva-utils
  )
  local dev_pkgs=(
    docker docker-compose
  )
  local wm_pkgs=(
    i3-wm i3status i3lock bspwm sxhkd dmenu picom slim rofi exo libmp4v2 cmus
    gvfs network-manager-applet playerctl pamixer light feh pcmanfm xarchiver
    networkmanager file-roller terminator opusfile wavpack bluez blueman
    bluez-utils cdrtools pavucontrol numlockx scrot nitrogen cpio arj lrzip lz4
    lzip
  )
  local app_pkgs=(
    gparted ghostscript bleachbit gedit
    firefox transmission-gtk gimp libreoffice-fresh libreoffice-fresh-pt-br
    virtualbox virtualbox-host-modules-arch virtualbox-guest-iso telegram-desktop neofetch
    code arc-gtk-theme lxappearance gsimplecal gwenview vlc epdfview
  )

  log "Installing base packages"
  install_packages "${base_pkgs[@]}"

  log "Installing Xorg and audio packages"
  install_packages "${xorg_pkgs[@]}"

  log "Installing CLI packages"
  install_packages "${cli_pkgs[@]}"

  log "Installing fonts"
  install_packages "${font_pkgs[@]}"

  log "Installing Dell Inspiron 15 3520 laptop packages"
  install_packages "${laptop_pkgs[@]}"

  log "Installing Intel graphics packages"
  install_packages "${intel_video_pkgs[@]}"

  log "Installing development packages"
  install_packages "${dev_pkgs[@]}"

  log "Installing window manager packages"
  install_packages "${wm_pkgs[@]}"

  log "Installing desktop apps"
  install_packages "${app_pkgs[@]}"
}

set_install_i3() {
  set_pacman
  set_pkgs
  pass_root
  set_lang
  name_machine
  boot_grub
  set_user
  set_services

  cat <<EOF

To finish, reboot the system and install AUR packages with your preferred helper:
polybar nerd-fonts-complete wd719x-firmware aic94xx-firmware paper-icon-theme
google-chrome i3lock-fancy-git
EOF
}

case "${1:-}" in
  -i|--install) set_install_i3 ;;
  -u|--remove) set_remove ;;
  -h|--help) usage ;;
  "") usage; exit 1 ;;
  *) usage; die "invalid option: $1" ;;
esac
