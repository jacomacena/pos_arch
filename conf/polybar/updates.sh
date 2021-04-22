#!/bin/bash

# echo
# echo 'updates.sh: "pacman -Syu"'
# echo
# sudo pacman -Syu

echo
echo 'updates.sh: "pacman -Syu"'
echo
read -p "Press A for aur... " stat

if [ "$stat" == "A" ]
then
		pacman -Syu
else
		pacman -Syyyyyuuuuu
fi

echo
read -p "Press enter to close this window..."
