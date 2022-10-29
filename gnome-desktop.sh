#!/bin/bash
#
# This script install gnome-session a pre-installed arch linux
# A user with sudo permissions and a live network connection is needed
#

# Set up logging
exec 1> >(tee "gnome_setup_out")
exec 2> >(tee "gnome_setup_err")

log(){
    echo "          * $1 *          "
    now=$(date +"%T")
    echo "$now $1" >> gnome_setup_log
}

check(){
    if [ "$1" != 0 ]; then
	echo "$2 error : $1" | tee -a gnome_setup_log
	exit 1
    fi
}

log "Refreshing package database"
sudo pacman -Sy
check "$?" "pacman"


# log "Installing git"
# sudo pacman -S --noconfirm --needed git


# log "Cloning repo"
# git clone https://github.com/amidonc/
# cd 


log "Installing needed official packages"
sudo pacman -S --noconfirm --needed - < package_lists/packages
check "$?" "pacman"

# log "Copying terminus-ttf fonts to font directory"
# sudo cp -f fonts/*.* /usr/share/fonts/
# check "$?" "cp"

# log "Copying settings to home folder"
# cp -f -R home/. ~/
# check "$?" "cp"

# log "Syncing hwclock"
# sudo hwclock -w
# check "$?" "hwclock"
                          
# log "Starting services"
# sudo systemctl enable acpid --now
# sudo systemctl enable iwd --now
# sudo systemctl enable bluetooth --now
# sudo systemctl enable cups --now

log "Installing aur packages"
me="$(whoami)"
cat package_lists/aur_packages | while read line 
do
    log "Installing $line"
    cd /opt/
    sudo git clone https://aur.archlinux.org/$line.git
    sudo chown -R $me:users $line 
    cd $line
    makepkg -si --skippgpcheck --noconfirm
    check "$?" "makepkg"
    sudo pacman -U --noconfirm *.pkg.tar.zst
    check "$?" "pacman -U"
    cd ..
done

log "Changing shell to zsh"
sudo chsh -s /bin/zsh
check "$?" "chsh"

log "Setting shell in /etc/default/useradd to zsh"
sudo sed -i 's+SHELL=/bin/bash+SHELL=/bin/zsh+g' /etc/default/useradd
check "$?" "sed"

log "Setting boot loader timeout to zero"
sudo sed -i 's+timeout 3+timeout 0+g' /boot/loader/loader.conf
check "$?" "sed"

# log "Cleaning up"
# cd ..
# rm -f -R <repo>
# check "$?" "rm"

log "Setup is done, please log out and log in back again ( type exit )"
