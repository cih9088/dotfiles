# dotfiles
tested on macOS, Ubuntu, and Redhat.

## Get this repository

```bash
# clone the repository
$ cd ~
$ git clone --recursive https://github.com/cih9088/dotfiles.git ~/dotfiles

# or pull in case you have cloned it already
$ cd ~/dotfiles
$ git pull
$ git submodule update --init --recursive

# make sure that you have following commands `make`, `git`, `sudo`
$ command -V make git sudo

# install them if not exist
# debian
$ apt update && apt install -y make git sudo
# redhat
$ dnf install -y make git sudo
```

## Prerequisites
The following list would be installed in your system. You need privilege (`sudo`).
No need if you have them on your system.
```bash
$ cd ~/dotfiles
$ ./bin/dots test-prerequisites      # Verify which commands are installed
$ ./bin/dots install prerequisites   # Install prerequisites (previlege is needed)
```

## Environement Variables
- `GH_ACCESS`: give maximum of 5,000 rate limits to github REST API \
ex) `GH_ACCESS=client_id:client_secret dots [...]`
- `PREFIX`: change path to install locally (default: `$HOME/.local`) \
ex) `PREFIX=/path/to/install dots [...]`

## `dots` command

- **systemwide**: others could execute those commands (need privilege)
- **locally**: others could not (All of commands and libraries would be installed in `PREFIX` (deafult: `$HOME/.local`) )

**NOTE**: systemwide install is preferred for macOS.

### One-liner
- Non-interactive install all listed in `config.yaml`
  - default mode is local: `dots install --mode local --config config.yaml`
  - default mode is system (prefer way for mac): `dots install --mode system --config config.yaml`
- Non-interactive update all listed in `config.yaml`
  - default mode is local: `dots update --mode local --config config.yaml`
  - default mode is system (prefer way for mac): `dots update --mode system --config config.yaml`
- Update dotfiles only: `dots update --yes configs bins`

### List
```bash
$ cd ~/dotfiles
$ ./bin/dots list
```

### Install

```bash
$ cd ~/dotfiles
# Install zsh interactively with dependencies (to install it locally you must install dependencies as well)
$ ./bin/dots install zsh
# Install zsh interactively without dependencies
$ ./bin/dots install --skip-dependencies zsh
# Install the latest zsh non-interactively
$ ./bin/dots install --mode local --yes zsh
# Install zsh version of 5.9 non-interactively
$ ./bin/dots install --mode local --yes --version 5.9 --skip-dependencies zsh
```

### Remove

```bash
$ cd ~/dotfiles
# Remove zsh interactively (remove command implicitly applies `--skip-dependencies`)
$ ./bin/dots remove zsh
# Remove locally installed zsh non-interactively
$ ./bin/dots remove--mode local --yes zsh
```

### Update
```bash
$ cd ~/dotfiles
# Update zsh interactively with dependencies (to install it locally you must install dependencies as well)
$ ./bin/dots update zsh
# Update zsh interactively without dependencies
$ ./bin/dots update --skip-dependencies zsh
# Update the latest zsh non-interactively
$ ./bin/dots update --mode local --yes zsh
# Update zsh version of 5.9 non-interactively
$ ./bin/dots update --mode local --yes --version 5.9 --skip-dependencies zsh
```

### Change-shell
```bash
$ cd ~/dotfiles
$ ./bin/dots change-shell
```

## [Initialise macOS](https://github.com/donnemartin/dev-setup#osxprepsh-script)
Setup macOS development environment with easy. Mostly copied from [here](https://github.com/donnemartin/dev-setup).
```bash
$ cd ~/dotfiles
$ make initMac
```



<!-- ## Highligts -->
<!--  -->
<!-- ### List of Dev environment that would be installed -->
<!-- - installDevPython: [pyenv](https://github.com/pyenv/pyenv), [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv), [pyenv-virtualenvwrapper](https://github.com/pyenv/pyenv-virtualenvwrapper), python2, python3 -->
<!-- - installDevNodejs: [nodejs](https://nodejs.org/en/) -->
<!-- - installDevShell: [shellchecker](https://www.shellcheck.net/), [bash-language-client](https://github.com/mads-hartmann/bash-language-server) -->
<!-- - installDevC: [ccls](https://github.com/MaskRay/ccls) -->
<!-- - installDevGo: [goenv](https://github.com/syndbg/goenv), golang -->
<!-- - installDevAsdf: [asdf](https://github.com/asdf-vm/asdf) -->
<!--  -->
<!-- ### [zsh](https://github.com/tmux/tmux) -->
<!-- For more detailed information please refer [zshrc](https://github.com/cih9088/dotfiles/blob/master/zsh/zshrc) -->
<!-- - show tips: `$ tips` -->
<!--  -->
<!-- ### [prezto](https://github.com/sorin-ionescu/prezto) -->
<!-- For more detailed information please refer [zpreztorc](https://github.com/cih9088/dotfiles/blob/master/zsh/zpreztorc) -->
<!-- - imported modules \ -->
<!-- [environment](https://github.com/sorin-ionescu/prezto/tree/master/modules/environment) -->
<!-- , [terminal](https://github.com/sorin-ionescu/prezto/tree/master/modules/terminal) -->
<!-- , [editor](https://github.com/sorin-ionescu/prezto/tree/master/modules/editor) -->
<!-- , [history](https://github.com/sorin-ionescu/prezto/tree/master/modules/history) -->
<!-- , [directory](https://github.com/sorin-ionescu/prezto/tree/master/modules/directory) -->
<!-- , [spectrum](https://github.com/sorin-ionescu/prezto/tree/master/modules/spectrum) -->
<!-- , [utility](https://github.com/sorin-ionescu/prezto/tree/master/modules/utility) -->
<!-- , [completion](https://github.com/sorin-ionescu/prezto/tree/master/modules/completion) -->
<!-- , [fasd](https://github.com/sorin-ionescu/prezto/tree/master/modules/fasd) -->
<!-- , [git](https://github.com/sorin-ionescu/prezto/tree/master/modules/git) -->
<!-- , [archive](https://github.com/sorin-ionescu/prezto/tree/master/modules/archive) -->
<!-- , [rsync](https://github.com/sorin-ionescu/prezto/tree/master/modules/rsync) -->
<!-- , [ssh](https://github.com/sorin-ionescu/prezto/tree/master/modules/ssh) -->
<!-- , [tmux-xpanes](https://github.com/belak/prezto-contrib/tree/master/tmux-xpanes) -->
<!-- , [syntax-highlighting](https://github.com/sorin-ionescu/prezto/tree/master/modules/syntax-highlighting) -->
<!-- , [history-substring-search](https://github.com/sorin-ionescu/prezto/tree/master/modules/history-substring-search) -->
<!-- , [autosuggestions](https://github.com/sorin-ionescu/prezto/tree/master/modules/autosuggestions) -->
<!-- , [prompt](https://github.com/sorin-ionescu/prezto/tree/master/modules/prompt) -->
<!--  -->
<!-- ### [nvim](https://github.com/neovim/neovim) -->
<!-- For detailed information and plugins please refer [init.vim](https://github.com/cih9088/dotfiles/blob/master/vim/vimrc) -->
<!-- - Few settings automatically disabled with files larger than 50mb -->
<!-- - leader: <kbd>,</kbd> or <kbd>\\</kbd> -->
<!-- - nohighlight: <kbd>leader</kbd> + <kbd>Space</kbd> -->
<!-- - toggle paste mode: <kbd>F2</kbd> -->
<!-- - buffers -->
<!--     - new buffer: <kbd>Ctrl</kbd> + <kbd>b</kbd> -->
<!--     - close buffer: <kbd>leader</kbd> + <kbd>b</kbd> + <kbd>x</kbd> -->
<!--     - navigate buffer: <kbd>\]</kbd> + <kbd>b</kbd>, <kbd>\[</kbd> + <kbd>b</kbd> -->
<!--     - go back to previous buffer: <kbd>Ctrl</kbd> + <kbd>w</kbd> + <kbd>Tab</kbd> -->
<!-- - tabs -->
<!--     - new tab: <kbd>Ctrl</kbd> + <kbd>t</kbd> -->
<!--     - close tab: <kbd>leader</kbd> + <kbd>t</kbd> + <kbd>x</kbd> -->
<!--     - navigate tab: <kbd>\]</kbd> + <kbd>t</kbd>, <kbd>\[</kbd> + <kbd>t</kbd> -->
<!-- - splits -->
<!--     - navigate split: <kbd>Ctrl</kbd> + [ <kbd>h</kbd>, <kbd>j</kbd>, <kbd>k</kbd>, <kbd>l</kbd> ] -->
<!--     - horizontal split: <kbd>Ctrl</kbd> + <kbd>w</kbd> + <kbd>h</kbd> -->
<!--     - vertical split: <kbd>Ctrl</kbd> + <kbd>w</kbd> + <kbd>v</kbd> -->
<!--     - resize split: <kbd>&uparrow;</kbd>, <kbd>&downarrow;</kbd>, <kbd>&leftarrow;</kbd>, <kbd>&rightarrow;</kbd> -->
<!--     - equal split: <kbd>Ctrl</kbd> + <kbd>w</kbd> + <kbd>=</kbd> -->
<!-- - system clipboard -->
<!--     - yank to system clipboard: <kbd>leader</kbd> + <kbd>y</kbd> -->
<!--     - cut to system clipboard: <kbd>leader</kbd> + <kbd>x</kbd> -->
<!--     - paste from system clipboard: <kbd>leader</kbd> + <kbd>p</kbd> -->
<!-- - Redirect the output of a vim or external command into a scratch buffer: `:Redir hi` or `:Redir !ls -al` -->
<!-- - replace a word under the curser or visually select then -->
<!--     - <kbd>c</kbd> + <kbd>*</kbd> -->
<!--     - repeat: <kbd>.</kbd> -->
<!--     - skip: <kbd>n</kbd> -->
<!-- - terminal -->
<!--     - open terminal horizontally: `:TermHorizontal` -->
<!--     - open terminal vertically: `:TermVertical` -->
<!--     - open terminal in floating window: `:TermFloat` -->
<!--     - open terminal <kbd>leader</kbd> + <kbd>R</kbd> -->
<!-- - toggle conceal level: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>a</kbd> -->
<!-- - simple calculator -->
<!--     - after visual selection: <kbd>Q</kbd> -->
<!-- - [vim-unimpaired](https://github.com/tpope/vim-unimpaired) -->
<!--     - navigate quickfix list: <kbd>\]</kbd> + <kbd>q</kbd>, <kbd>\[</kbd> + <kbd>q</kbd> -->
<!--     - navigate location list: <kbd>\]</kbd> + <kbd>l</kbd>, <kbd>\[</kbd> + <kbd>l</kbd> -->
<!--     - navigate SCM conflict: <kbd>\]</kbd> + <kbd>n</kbd>, <kbd>\[</kbd> + <kbd>n</kbd> -->
<!--     - toggle diff: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>d</kbd> -->
<!--     - toggle relativenumber: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>r</kbd> -->
<!--     - toggle number: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>n</kbd> -->
<!--     - toggle wrap: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>w</kbd> -->
<!-- - [vim-signify](https://github.com/mhinz/vim-signify) -->
<!--     - navigate hunk: <kbd>\]</kbd> + <kbd>c</kbd>, <kbd>\[</kbd> + <kbd>c</kbd> -->
<!-- - [vim-easy-aline](https://github.com/junegunn/vim-easy-align) -->
<!-- - [vim-fugitive](https://github.com/tpope/vim-fugitive) -->
<!--     - open Gstatus: <kbd>leader</kbd> + <kbd>G</kbd> -->
<!-- - [vista](https://github.com/liuchengxu/vista.vim) -->
<!--     - toggle tagbar: <kbd>leader</kbd> + <kbd>T</kbd> -->
<!-- - [coc.nvim](https://github.com/neoclide/coc.nvim): autocompletion and more -->
<!--     - navigate diagnostic: <kbd>\[</kbd> + <kbd>d</kbd>, <kbd>\]</kbd> + <kbd>d</kbd> -->
<!--     - go to definition: <kbd>g</kbd> + <kbd>d</kbd> -->
<!--     - go to implemtation: <kbd>g</kbd> + <kbd>i</kbd> -->
<!--     - preview document: <kbd>K</kbd> -->
<!--     - [ultisnips](https://github.com/SirVer/ultisnips): snippet -->
<!--         - expand or jump forward: <kbd>Ctrl</kbd> + <kbd>j</kbd> -->
<!--         - expand: <kbd>Ctrl</kbd> + <kbd>l</kbd> -->
<!--         - jump forward: <kbd>Ctrl</kbd> + <kbd>j</kbd> -->
<!--         - jump backward: <kbd>Ctrl</kbd> + <kbd>k</kbd> -->
<!-- [> - [deoplete](https://github.com/Shougo/deoplete.nvim): autocompletion <] -->
<!-- [>     - forward: <kbd>Tab</kbd> <] -->
<!-- [>     - backward: <kbd>Shift</kbd> + <kbd>Tab</kbd> <] -->
<!-- [> - [neosnippet](https://github.com/Shougo/neosnippet.vim): snippet <] -->
<!-- [>     - expand or jump: <kbd>Ctrl</kbd> + <kbd>k</kbd> <] -->
<!-- [>     - jump: <kbd>Tab</kbd> <] -->
<!-- - [fzf](https://github.com/junegunn/fzf.vim): fuzzy finder -->
<!--     - open Files: <kbd>leader</kbd> + <kbd>F</kbd> -->
<!--     - open ProjectFiles: <kbd>leader</kbd> + <kbd>P</kbd> -->
<!--     - open Buffers: <kbd>leader</kbd> + <kbd>B</kbd> -->
<!--     - open History: <kbd>leader</kbd> + <kbd>H</kbd> -->
<!--     - open Commits: <kbd>leader</kbd> + <kbd>C</kbd> -->
<!--     - open Blines: <kbd>leader</kbd> + <kbd>L</kbd> -->
<!-- - [vim-startify](https://github.com/mhinz/vim-startify): nice start -->
<!--     - open startify: <kbd>leader</kbd> + <kbd>S</kbd> -->
<!-- - [vim-sandwich](https://github.com/machakann/vim-sandwich): easy surrounding modification -->
<!--     - add surrounding: <kbd>s</kbd> + <kbd>a</kbd> + {motion/text object} + {addition} -->
<!--     - delete surrounding: <kbd>s</kbd> + <kbd>d</kbd> + {deletion} -->
<!--     - replace surrounding: <kbd>s</kbd> + <kbd>r</kbd> + {deletion} + {addition} -->
<!-- - [vim-dirvish](https://github.com/justinmk/vim-dirvish): file explore -->
<!--     - open dirvish: <kbd>-</kbd> -->
<!--     - reload: <kbd>g</kbd> + <kbd>r</kbd> -->
<!--     - go to home: <kbd>g</kbd> + <kbd>~</kbd> -->
<!--     - hide hiddden files: <kbd>g</kbd> + <kbd>h</kbd> -->
<!-- [> - [vim-rooter](https://github.com/airblade/vim-rooter): change pwd to project root. usefule with fzf <] -->
<!-- [>     - run rooter: <kbd>leader</kbd> + <kbd>R</kbd> <] -->
<!-- - [nerdcommenter](https://github.com/scrooloose/nerdcommenter): Comment out easily -->
<!--     - toggle comment: <kbd>leader</kbd> + <kbd>c</kbd> + <kbd>Space</kbd> -->
<!--     - invert comment: <kbd>leader</kbd> + <kbd>c</kbd> + <kbd>i</kbd> -->
<!--     - yank and comment: <kbd>leader</kbd> + <kbd>c</kbd> + <kbd>y</kbd> -->
<!-- - [auto-pair](https://github.com/jiangmiao/auto-pairs) -->
<!--     - insert parens purely: <kbd>Ctrl</kbd> + <kbd>v</kbd> + {paren} -->
<!-- [> - [splitjoin](https://github.com/AndrewRadev/splitjoin.vim) <] -->
<!-- [>     - split one-liner into multiple lines: <kbd>g</kbd> + <kbd>S</kbd> <] -->
<!-- [>     - join a block into single-line statement: <kbd>g</kbd> + <kbd>J</kbd> <] -->
<!--  -->
<!-- ### [tmux](https://github.com/tmux/tmux) -->
<!-- For more detailed information please refer [tmux.conf](https://github.com/cih9088/dotfiles/blob/master/tmux/tmux.conf) -->
<!-- - prefix: <kbd>Ctrl</kbd> + <kbd>a</kbd> -->
<!-- - detach: <kbd>prefix</kbd> + <kbd>d</kbd> -->
<!-- - reload config file: <kbd>prefix</kbd> + <kbd>r</kbd> -->
<!-- - go to pane with fzf: <kbd>prefix</kbd> + <kbd>0</kbd> -->
<!-- - window -->
<!--     - create new window: <kbd>prefix</kbd> + <kbd>c</kbd> -->
<!--     - kill current window: <kbd>prefix</kbd> + <kbd>X</kbd> -->
<!--     - navigate window: <kbd>prefix</kbd> + [ <kbd>1</kbd>, ..., <kbd>9</kbd> ] -->
<!--     - navigate window alternatively: <kbd>prefix</kbd> + <kbd>'</kbd> + {window index} -->
<!--     - rename window: <kbd>prefix</kbd> + <kbd>,</kbd> -->
<!--     - swap current window: <kbd>prefix</kbd> + [ <kbd>\<</kbd>, <kbd>\></kbd> ] -->
<!-- - pane -->
<!--     - split current pane vertically: <kbd>prefix</kbd> + <kbd>v</kbd> -->
<!--     - split current pane horizontally: <kbd>prefix</kbd> + <kbd>h</kbd> -->
<!--     - kill current pane: <kbd>prefix</kbd> + <kbd>x</kbd> -->
<!--     - navigate pane: <kbd>prefix</kbd> + [ <kbd>h</kbd>, <kbd>j</kbd>, <kbd>k</kbd>, <kbd>l</kbd> ] -->
<!--     - resize pane: <kbd>prefix</kbd> + [ <kbd>H</kbd>, <kbd>J</kbd>, <kbd>K</kbd>, <kbd>L</kbd> ] -->
<!--     - swap current pane: <kbd>prefix</kbd> + [ <kbd>[</kbd>, <kbd>]</kbd> ] -->
<!-- - copy mode -->
<!--     - enter copy mode: <kbd>prefix</kbd> + <kbd>enter</kbd> -->
<!--     - select region: <kbd>v</kbd> -->
<!--     - copy selected region: <kbd>y</kbd> -->
<!--     - append selected region to clipboard: <kbd>A</kbd> -->
<!--     - copy current line: <kbd>Y</kbd> -->
<!--     - copy from the cursor to the end of the line: <kbd>D</kbd> -->
<!-- - toggle -->
<!--     - synchronizing mode: <kbd>prefix</kbd> + <kbd>e</kbd> -->
<!--     - mouse mode: <kbd>prefix</kbd> + <kbd>m</kbd> -->
<!--     - maximizing pane: <kbd>prefix</kbd> + <kbd>z</kbd> -->
<!--     - advanced maximizing pane: <kbd>prefix</kbd> + <kbd>+</kbd> (require tmux version > 2.8) -->
<!--     - disable tmux: <kbd>F12</kbd> (useful in nested tmux) -->
<!-- - [tmux-resurrect](https://github.com/cih9088/tmux-resurrect) -->
<!--     - save tmux environment: <kbd>prefix</kbd> + <kbd>Ctrl</kbd> + <kbd>s</kbd> -->
<!--     - restore tmux environment: <kbd>prefix</kbd> + <kbd>Ctrl</kbd> + <kbd>r</kbd> -->
<!-- [> - renew environment variables (e.g. DISPLAY): <kbd>prefix</kbd> + <kbd>\$</kbd> <] -->

<!-- ## Issues -->
<!-- 1. ~~Showing following error message at the top of terminal when the zsh 5.5 +  started \ -->
<!--     `/var/folders/vp/15xrzrrj4sx0dd3k6gsv1hmw0000gn/T//prezto-fasd-cache.501.zsh:compctl:17: unknown condition code:`~~ -->
<!--     > [it is now fixed with zsh 5.6.1 + ](https://github.com/sorin-ionescu/prezto/issues/1569) -->
<!--  -->
<!-- 2. Showing abnormal font like below image -->
<!--     > ![abnormal font](https://imgur.com/wSb49GM.png) \ -->
<!--     > [nerd font](https://github.com/ryanoasis/nerd-fonts) patched font is needed or change `g:lightline#bufferline#enable_devcons` to 0 in `.vimrc` -->
<!--  -->
<!-- 3. vim colorscheme is somewhat weird -->
<!--     > run `truecolour-test` script if your terminal or terminal inside of tmux support truecolor. This should show smooth color transition if supported. [related issue](https://github.com/tmux/tmux/issues/1246) -->
<!--  -->
<!--     - true color supported \ -->
<!--     ![truecolor supported](https://imgur.com/Fnx9P2Y.png) -->
<!--     - true color not supported \ -->
<!--     ![truecolor not supported](https://imgur.com/vsOcuqx.png) -->
<!--  -->
<!-- 4. virtualenvwrapper is not installed propely. -->
<!--     > `pip install virtualenv` first -->
<!--  -->
<!-- 5. `make updateTPM` shows an error like `unknown variable: TMUX_PLUGIN_MANAGER_PATH` -->
<!--     > Completely quit tmux and try again ([pull](https://github.com/tmux-plugins/tpm/pull/186)) -->
<!--  -->
<!--  -->
<!-- ## TODO -->
