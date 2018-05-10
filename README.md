# dotfiles
This is my dot files.

## Get this repository
```bash
$ cd ~
$ git clone https://github.com/cih9088/dotfiles.git ~/dotfiles
```

## Prerequisites
You need sudo
```bash
$ cd ~/dotfiles
$ ./prerequisites.sh
```

## Install it as whole
```bash
$ cd ~/dotfiles
$ ./install.sh local    # if you want to install locally
$ ./install.sh          # if you want to install system-wide
```

## Setup virtual env
```bash
$ cd ~/dotfiles
$ ./setup_virtualenv.sh
```

<!--
## For MAC
Install [brew](https://brew.sh/index_ko.html) first
```bash
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Installation of [Prezto](https://github.com/sorin-ionescu/prezto)
1. Install zsh
    ```bash
    $ brew install zsh            # For Mac
    $ sudo apt-get install zsh    # For Ubuntu
    ```
2. Launch zsh
    ```bash
    $ zsh
    ```
3. Run prezto_setup.sh
    ```bash
    $ ./script/prezto_setup.sh
    ```
4. (Optional) Set Zsh as your default shell
    ```bash
    $ chsh -s /bin/zsh
    ```

## Installation of [neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim) and plugin setup
---
**MAC ONLY**: You need to install Python2 and Python3 managed by Homebrew
```bash
$ brew install python2  # python2
$ brew install python   # python3
```
---

1. Install neovim
    ```bash
    # For Mac
    $ brew install neovim

    # For Ubuntu
    $ sudo apt-get install software-properties-common
    $ sudo add-apt-repository ppa:neovim-ppa/stable
    $ sudo apt-get update
    $ sudo apt-get install neovim
    $ sudo apt-get install python-dev python-pip python3-dev python3-pip
    ```

2. Install neovim with python3 support
	```bash
	$ pip3 install neovim --upgarde
	```

3. Install [fd](https://github.com/sharkdp/fd)
    ```bash
    $ brew install fd                   # For Mac
    $ sudo dpkg -i fd_6.2.0_amd64.deb   # adapt version number and architecture
    ```

## Installation of tmux
1. Run tmux_setup.sh
    ```bash
    $ ./script/tmux_setup.sh
    ```

## Copy dot files
1. Run dot_setup.sh
    ```bash
    $ cd script # important! you have to be in script directory!!
    $ ./dot_setup.sh
    ```
-->
