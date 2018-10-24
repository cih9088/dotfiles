# dotfiles
This is my dotfiles. Only tested in OSX and Ubuntu.

## Get this repository
```bash
$ cd ~
$ git clone https://github.com/cih9088/dotfiles.git ~/dotfiles
```

## Prerequisites
You need sudo and following would be installed. If you have installed already, no need.
* OSX: python2, python3, wget
* Ubuntu: python2, python3

```bash
$ cd ~/dotfiles
# You have to be in dotfiles directory!!
$ make prerequisites
```
<!-- ```bash -->
<!-- $ cd ~/dotfiles -->
<!-- # You have to be in dotfiles directory!! -->
<!-- $ ./prerequisites.sh -->
<!-- ``` -->

## Install it as a whole
If you choose to install systemwide, other users could execute thoes command.
(homebrew for OSX and apt-get for Ubuntu will be used.)
If you choose to install locally, others not.
(All of command would be installed in `$HOME/.local`)
```bash
$ cd ~/dotfiles
$ make installAll
```

## Update dotfiles
```bash
$ cd ~/dotfiles
$ make updateAll
```
<!-- ## Install it as a whole -->
<!-- Following list would be installed by itself with prompt.  -->
<!-- If you choose to install systemwide, other users could execute thoes command. -->
<!-- (homebrew for OSX and apt-get for Ubuntu will be used.) -->
<!-- If you choose to install locally, others not. -->
<!-- (All of command would be installed in `$HOME/.local`) -->
<!-- * [zsh](http://www.zsh.org/) -->
<!-- * [prezto](https://github.com/sorin-ionescu/prezto) -->
<!-- * personal dotfiles -->
<!-- * [neovim](https://neovim.io/) and plugins (please refer `init.vim` for the details) -->
<!-- * [tmux](https://github.com/tmux/tmux) -->
<!-- * personal bin -->
<!--     [> * [tree](https://linux.die.net/man/1/tree) <] -->
<!--     [> * [fd](https://github.com/sharkdp/fd) <] -->
<!--     [> * [thefuck](https://github.com/nvbn/thefuck) <] -->
<!--     [> * [ripgrep](https://github.com/nvbn/thefuck) <] -->
<!--     [> * [trdl](https://github.com/tldr-pages/tldr) <] -->
<!--     [> * [ranger](https://github.com/ranger/ranger) <] -->
<!--     [> * [bash-snippets (transfer, cheat only)](https://github.com/alexanderepstein/Bash-Snippets) <] -->
<!-- ```bash -->
<!-- $ cd ~/dotfiles -->
<!-- # You have to be in dotfiles directory!! -->
<!-- $ ./install.sh -->
<!-- # Only if you need my dev environment -->
<!-- $ ./setup_python_dev.sh     # setup python dev environment -->
<!-- $ ./setup_shell_dev.sh      # setup shell dev envrionment -->
<!-- ``` -->

## Issues
1. ~~Showing following error message at the top of terminal when the zsh 5.5+ started \
    `/var/folders/vp/15xrzrrj4sx0dd3k6gsv1hmw0000gn/T//prezto-fasd-cache.501.zsh:compctl:17: unknown condition code:`~~ \
    -> [it is now fixed with zsh 5.6.1+](https://github.com/sorin-ionescu/prezto/issues/1569)

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
