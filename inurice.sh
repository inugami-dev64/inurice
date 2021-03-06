#!/bin/sh

# How many cpu threads to use for compilation
[ -z "$CPUS" ] && CPUS=4

# Pacman dependencies
PACMAN_PROGRAMS="alsa-utils \
                 base-devel \
                 biber \
                 ctags \
                 clang \
                 feh \
                 ffmpeg \
                 gcr \
                 git \
                 htop \
                 man \
                 mpv \
                 neofetch \
                 neovim \
                 pamixer \
                 pulseaudio \
                 python-pip \
                 texlive-most \
                 thunderbird \
                 vifm \
                 webkit2gtk \
                 xfce4-screenshooter \
                 xcompmgr \
                 xorg-xinit \
                 xorg-server \
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
ST_GIT="https://git.sadblog.xyz/st"
SURF_GIT="https://git.suckless.org/surf"
TABBED_GIT="https://git.suckless.org/tabbed"
CHICAGO95_GIT="https://github.com/grassmunk/Chicago95"

# AUR dependencies
YAY_AUR="https://aur.archlinux.org/yay.git"
YAY_PROGRAMS="bear \
              kpcli"
    

# Ungoogled chromium binary upstream and gpg keys
UNGOOGLED_CHROMIUM_KEY="https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/x86_64/home_ungoogled_chromium_Arch.key"
UNGOOGLED_CHROMIUM_REPO='https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/$arch'

# Color definitions
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'


# Check if sudo is available
sudo_check() {
    if ! hash sudo 2>/dev/null
    then
        printf "Sudo executable not found, please make sure that sudo is installed and your user is in sudoers file\n"
        exit
    fi
}


# Clone a git repository, build and install it
# Argument $1 specifies the remote repository's url
# Argument $2 specifies the local clone directory
clone_and_build() {
    printf "${GREEN}Cloning and building $2...${NO_COLOR}\n"
    git clone $1 $2
    cd $2
    printf "Building $2...\n"
    make -j$CPUS
    sudo make install
    cd ..
}


# Special function to clone and build dwm
clone_and_build_dwm() {
    printf "${GREEN}Cloning and building dwm...${NO_COLOR}\n"
    git clone $DWM_GIT dwm
    cd dwm
    read -p "Please enter keepass database location (default: '~/Document/passwords.kdbx'): " PASSWORD_DB
    [ -z "$PASSWORD_DB" ] && PASSWORD_DB="~/Document/passwords.kdbx"

    # Build and install dwm
    make "PASSWORD_DB=${PASSWORD_DB}" -j$CPUS
    sudo make install
    cd ..
}


# Clone an AUR repository and perform makepkg on it to install
# Argument $1 specifies the remote repository's url
# Argument $2 specifies the local clone directory
clone_and_makepkg() {
    printf "${GREEN}Cloning and makepkg $2...${NO_COLOR}\n"
    git clone $1 $2
    cd $2
    makepkg -si
    cd ..
}


# Install all pacman programs
install_pacman() {
    printf "${YELLOW}Installing programs from pacman${NO_COLOR}\n"
    sudo pacman -S $PACMAN_PROGRAMS
}


# Install ungoogled chromium from OpenSUSE upstream
install_ungoogled_chromium() {
    UNGOOGLED_CHROMIUM_CONF="/etc/pacman.d/custom/ungoogled-chromium.conf"
    printf "${YELLOW}Installing ungoogled-chromium${NO_COLOR}\n"

    # Create /etc/pacman.d/custom directory if it does not exist
    if [ ! -d "/etc/pacman.d/custom" ]; then
        sudo mkdir -p /etc/pacman.d/custom
    fi

    curl -s $UNGOOGLED_CHROMIUM_KEY | sudo pacman-key -a -
    printf "[home_ungoogled_chromium_Arch]\nSigLevel = Required TrustAll\nServer = ${UNGOOGLED_CHROMIUM_REPO}\n" | sudo tee $UNGOOGLED_CHROMIUM_CONF > /dev/null

    # Check if entry "Include = /etc/pacman.d/custom/*" exists
    GREP_OUTPUT=$(grep "Include = ${UNGOOGLED_CHROMIUM_CONF}" /etc/pacman.conf)
    if [ -z "${GREP_OUTPUT}" ]; then
        printf "# Inurice\nInclude = ${UNGOOGLED_CHROMIUM_CONF}\n" | sudo tee --append /etc/pacman.conf > /dev/null
    fi

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
install_pacman
install_ungoogled_chromium

# Install ueberzug
sudo pip3 install ueberzug

# Clone and build base wm repositories
clone_and_build_dwm
clone_and_build $DMENU_GIT dmenu
clone_and_build $ST_GIT st

# Clone and build vanilla suckless utilities
clone_and_build $SURF_GIT surf
clone_and_build $TABBED_GIT tabbed

# Install yay with all AUR programs requested
clone_and_makepkg $YAY_AUR yay
yay -S $YAY_PROGRAMS

# Configure themes and stuff
install_chicago95_theme
configure

# End message
printf "\n${GREEN}Successfully riced your Arch linux installation\nRun 'startx' to start xorg${NO_COLOR}\n"
