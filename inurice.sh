#!/bin/sh

# How many cpu threads to use for compilation
CPUS=4

# Pacman dependencies
PACMAN_PROGRAMS="alsa-utils \
                 base-devel \
                 clangd \
                 feh \
                 ffmpeg \
                 git \
                 mpv \
                 neofetch \
                 nvim \
                 pulseaudio \
                 texlive-most \
                 thunderbird \
                 vifm \
                 xcompmgr \
                 xorg-setxkbmap \
                 xorg-xrandr \
                 xorg-xsetroot \
                 yt-dlp \
                 zathura \
                 zathura-pdf-mupdf"

# External dependencies
DMENU_GIT="https://git.sadblog.xyz/dmenu"
DOTFILES_GIT="https://git.sadblog.xyz/dotfiles"
DWM_GIT="https://git.sadblog.xyz/dwm"
KPCLI_AUR="https://aur.archlinux.org/kpcli.git"
ST_GIT="https://git.sadblog.xyz/st"
SURF_GIT="https://git.suckless.org/surf"
TABBED_GIT="https://git.suckless.org/tabbed"
CHICAGO95_GIT="https://github.com/grassmunk/Chicago95"

# Ungoogled chromium binary upstream and gpg keys
UNGOOGLED_CHROMIUM_KEY="https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/x86_64/home_ungoogled_chromium_Arch.key"
UNGOOGLED_CHROMIUM_REPO="https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/$arch"


# Check if sudo is available
sudo_check() {
    if [ ! -x sudo ]; then
        printf "Sudo executable not found, please make sure that sudo is installed and your user is in sudoers file\n"
        exit
    fi
}


# Clone a git repository, build and install it
# Argument $1 specifies the remote repository's url
# Argument $2 specifies the local clone directory
clone_and_build() {
    git clone $1 $2
    cd $2
    printf "Building $2...\n"
    make -j$CPUS
    sudo make install
    cd ..
}


# Clone an AUR repository and perform makepkg on it to install
# Argument $1 specifies the remote repository's url
# Argument $2 specifies the local clone directory
clone_and_makepkg() {
    printf "Building $2...\n"
    git clone $1 $2
    makepkg -si
    cd ..
}


# Install ungoogled chromium from OpenSUSE upstream
install_ungoogled_chromium() {
    curl -s $UNGOOGLED_CHROMIUM_KEY | sudo pacman-key -a -
    echo '
    [home_ungoogled_chromium_Arch]
    SigLevel = Required TrustAll
    Server = $UNGOOGLED_CHROMIUM_REPO' | sudo tee --append /etc/pacman.conf
    sudo pacman -Sy
    sudo pacman -S ungoogled-chromium
}


# Install Chicago95 theme for more SOVLful desktop
install_chicago95_theme() {
    printf "Cloning and installing Chicago95 themes...\n"
    git clone $CHICAGO95_GIT chicago95
    cd chicago95
    sudo cp -r Icons/Chicago95 /usr/share/icons
    sudo cp -r Theme/Chicago95 /usr/share/themes
    cd ..
}


# Install my dotfiles and run its bootstrap.sh script
configure() {
    git clone $DOTFILES_GIT dotfiles
    cd dotfiles
    chmod a+x bootstrap.sh
    ./bootstrap.sh
    cd ..
}


sudo_check

# Install all pacman dependecies
sudo pacman -S $PACMAN_PROGRAMS

# Clone and build base wm repositories
clone_and_build $DWM_GIT dwm
clone_and_build $DMENU_GIT dmenu
clone_and_build $ST_GIT st

# Clone and build vanilla suckless utilities
clone_and_build $SURF_GIT surf
clone_and_build $TABBED_GIT tabbed
clone_and_makepkg $KPCLI_AUR kpcli
install_ungoogled_chromium
install_chicago95_theme
configure
