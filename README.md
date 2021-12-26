# Inurice post-installation script

![](res/inuyasha.png)


This script allows to easily reproduce dwm configuration that I use on any Arch linux based distribution. 
In order to get started make sure that you have working internet connection and all graphics driver related
issues are resolved, especially if you are using any NVIDIA cards. Also make sure that sudo is installed and 
your user is already a sudoer. Otherwise the script will simply fail.


## Getting started

In order to start ricing Arch Linux build you can fetch the script directly from its website and run it:  
```  
$ curl -LO https://inurice.de/inurice.sh
$ chmod a+x inurice.sh
$ CPUS=<n> ./inurice.sh
```  

Keep in mind that the script will create some additional directories in its root directory that are mainly caused 
from git pulls. So in order to keep your home directory clean, reserve an additional directory for the script and its
dependencies that are git pulled.


## What does the script do?

First of all the script attempts to install a lot of programs that I personally consider to be necessary for any 
functional Linux desktop environment. The full list of all programs can be found [here](programs.csv) and the total size
on disk is about 4GB! If you are a turbo minimalist then you have been warned.  

In addition the script will also install my [dwm](https://git.sadblog.xyz/dwm), [dmenu](https://git.sadblog.xyz/dmenu) and 
[st](https://git.sadblog.xyz/st) builds and configure everything using my common [dotfiles](https://git.sadblog.xyz/dotfiles).
The GTK theme that will be used is going to be Chicago95, since it is objectively the best theme available for ricing GTK 
applications.
