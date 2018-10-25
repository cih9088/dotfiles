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
$ make prerequisites
```
<!-- ```bash -->
<!-- $ cd ~/dotfiles -->
<!-- # You have to be in dotfiles directory!! -->
<!-- $ ./prerequisites.sh -->
<!-- ``` -->

## How to install and update
If you just want to install dotfiles and nothing else,
`cd ~/dotfiles; make updateDotfiles`

### Install (The easy and recommended way)
If you can't be bothered to pay attention to the entire processes.
- If you choose to install systemwide, other users could execute thoes command. \
(**homebrew** for OSX and **apt-get** for Ubuntu will be used.)
- If you choose to install locally, others not.
(All of commands would be installed in `$HOME/.local/bin`)

```bash
$ cd ~/dotfiles
$ make installUpdateAll     # Install and update as a whole (recommended way)
```

### Update
For update configurations. \
Note that update does not update any of commands installed but dotfiles, neovimplugin, tmuxplugins, and own commands.
If you have installed with `make intallUpdateAll` at first, you don't need this.
```bash
$ cd ~/dotfiles
$ git pull
$ make updateAll    # Update all (recommended way)

# or you could choose what to update in following list
# [updateDotfiles, updateNeovimPlugins, updateTmuxPlugins, updateBins]
# For instance,
$ make updateDotfiles   # Update dotfiles only
```


### Advanced Install
```bash
$ cd ~/dotfiles
$ make installAll   # Install all

# or you could choose what to install in following list
# [installZsh, installPrezto, installNeovim, installTmux, installTPM, installBins]
# For instance,
$ make installNeovim        # Install neovim only
$ make installNeovim 0.2.0  # Specify version if intended to install locally
```


## Highligts

### [zsh](https://github.com/tmux/tmux)
For more detailed information please refer [zshrc](https://github.com/cih9088/dotfiles/blob/master/zsh/zshrc)
- show tips: `$ tips`

### [prezto](https://github.com/sorin-ionescu/prezto)
For more detailed information please refer [zpreztorc](https://github.com/cih9088/dotfiles/blob/master/zsh/zpreztorc)
- imported modules \
[environment](https://github.com/sorin-ionescu/prezto/tree/master/modules/environment)
, [terminal](https://github.com/sorin-ionescu/prezto/tree/master/modules/terminal)
, [editor](https://github.com/sorin-ionescu/prezto/tree/master/modules/editor)
, [history](https://github.com/sorin-ionescu/prezto/tree/master/modules/history)
, [directory](https://github.com/sorin-ionescu/prezto/tree/master/modules/directory)
, [spectrum](https://github.com/sorin-ionescu/prezto/tree/master/modules/spectrum)
, [utility](https://github.com/sorin-ionescu/prezto/tree/master/modules/utility)
, [completion](https://github.com/sorin-ionescu/prezto/tree/master/modules/completion)
, [fasd](https://github.com/sorin-ionescu/prezto/tree/master/modules/fasd)
, [tmux](https://github.com/sorin-ionescu/prezto/tree/master/modules/tmux)
, [git](https://github.com/sorin-ionescu/prezto/tree/master/modules/git)
, [archive](https://github.com/sorin-ionescu/prezto/tree/master/modules/archive)
, [rsync](https://github.com/sorin-ionescu/prezto/tree/master/modules/rsync)
, [python](https://github.com/sorin-ionescu/prezto/tree/master/modules/python)
, [autosuggestions](https://github.com/sorin-ionescu/prezto/tree/master/modules/autosuggestions)
, [syntax-highlighting](https://github.com/sorin-ionescu/prezto/tree/master/modules/syntax-highlighting)
, [history-substring-search](https://github.com/sorin-ionescu/prezto/tree/master/modules/history-substring-search)
, [ssh](https://github.com/sorin-ionescu/prezto/tree/master/modules/ssh)
, [prompt](https://github.com/sorin-ionescu/prezto/tree/master/modules/prompt)

### [nvim](https://github.com/neovim/neovim)
For detailed information and plugins please refer [init.vim](https://github.com/cih9088/dotfiles/blob/master/vim/vimrc)
- Few settings automatically disabled with files larger than 50mb
- leader: <kbd>,</kbd> or <kbd>\\</kbd>
- nohighlight: <kbd>leader</kbd>+<kbd>Space</kbd>
- buffers
    - new buffer: <kbd>Ctrl</kbd>+<kbd>b</kbd>
    - close buffer: <kbd>leader</kbd>+<kbd>b</kbd>+<kbd>q</kbd>
    - navigate buffer: <kbd>\]</kbd>+<kbd>b</kbd>, <kbd>\[</kbd>+<kbd>b</kbd>
    - go back to previous buffer: <kbd>Ctrl</kbd>+<kbd>w</kbd>+<kbd>Tab</kbd>
    - resize buffer: <kbd>&uparrow;</kbd>, <kbd>&downarrow;</kbd>, <kbd>&leftarrow;</kbd>, <kbd>&rightarrow;</kbd>
- tabs
    - new tab: <kbd>Ctrl</kbd>+<kbd>t</kbd>
    - close tab: <kbd>leader</kbd>+<kbd>t</kbd>+<kbd>q</kbd>
    - navigate tab: <kbd>\]</kbd>+<kbd>t</kbd>, <kbd>\[</kbd>+<kbd>t</kbd>
- splits
    - navigate split: <kbd>Ctrl</kbd>+<kbd>h</kbd>, <kbd>Ctrl</kbd>+<kbd>k</kbd>, <kbd>Ctrl</kbd>+<kbd>l</kbd>, <kbd>Ctrl</kbd>+<kbd>;</kbd>
    - horizontal split: <kbd>Ctrl</kbd>+<kbd>w</kbd>+<kbd>h</kbd>
    - vertical split: <kbd>Ctrl</kbd>+<kbd>w</kbd>+<kbd>v</kbd>
- system clipboard
    - yank to system clipboard: <kbd>leader</kbd>+<kbd>y</kbd>
    - cut to system clipboard: <kbd>leader</kbd>+<kbd>x</kbd>
    - paste from system clipboard: <kbd>leader</kbd>+<kbd>p</kbd>
- search in current visible window: `:WinSearch {args}`
- python breakpoint: <kbd>leader</kbd>+<kbd>b</kbd>
- replace a word under the curser or visually select then
    - <kbd>c</kbd>+<kbd>*</kbd>
    - repeat: <kbd>.</kbd>
    - skip: <kbd>n</kbd>
- terminal
    - open terminal horizontally: `:T`
    - open terminal vertically: `:VT`
- toggle conceal level: <kbd>y</kbd>+<kbd>o</kbd>+<kbd>a</kbd>
- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)
- [easymotion](https://github.com/easymotion/vim-easymotion): fast movement
    - <kbd>s</kbd>+{char}+{char}
- [tagbar](https://github.com/majutsushi/tagbar)
    - toggle tagbar: <kbd>leader</kbd>+<kbd>T</kbd>
- [deoplete](https://github.com/Shougo/deoplete.nvim): autocompletion
    - forward: <kbd>Tab</kbd>
    - backward: <kbd>Shift</kbd>+<kbd>Tab</kbd>
- [neosnippet](https://github.com/Shougo/neosnippet.vim): snippet
    - expand or jump: <kbd>Ctrl</kbd>+<kbd>k</kbd>
    - jump: <kbd>Tab</kbd>
- [fzf](https://github.com/junegunn/fzf.vim): fuzzy finder
    - open Files: <kbd>leader</kbd>+<kbd>F</kbd>
    - open Buffers: <kbd>leader</kbd>+<kbd>B</kbd>
    - open History: <kbd>leader</kbd>+<kbd>H</kbd>
    - open Commits: <kbd>leader</kbd>+<kbd>C</kbd>
    - open Blines: <kbd>leader</kbd>+<kbd>L</kbd>
- [vim-startify](https://github.com/mhinz/vim-startify): nice start
    - open startify: <kbd>leader</kbd>+<kbd>S</kbd>
- [ctrlsf](https://github.com/dyng/ctrlsf.vim): powerful search
    - search prompt: <kbd>Ctrl</kbd>+<kbd>f</kbd>+<kbd>f</kbd>
- [vim-sandwich](https://github.com/machakann/vim-sandwich): easy surrounding modification
    - add surrounding: <kbd>s</kbd>+<kbd>a</kbd>+{motion/text object}+{addition}
    - delete surrounding: <kbd>s</kbd>+<kbd>d</kbd>+{deletion}
    - replace surrounding: <kbd>s</kbd>+<kbd>r</kbd>+{deletion}+{addition}
- [vim-dirvish](https://github.com/justinmk/vim-dirvish): file explore
    - open dirvish: <kbd>-</kbd>
- [vim-rooter](https://github.com/airblade/vim-rooter): change pwd to project root. usefule with fzf
    - run rooter: <kbd>leader</kbd>+<kbd>R</kbd>
- [vim-easyaline](https://github.com/junegunn/vim-easy-align)

### [tmux](https://github.com/tmux/tmux)
For more detailed information please refer [oh my tmux](https://github.com/gpakosz/.tmux)
- prefix: <kbd>Ctrl</kbd>+<kbd>a</kbd>
- toggle disable: <kbd>F12</kbd> (useful nested tmux)

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
