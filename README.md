# Andy's dotfiles
![my dotfiles](https://i.imgur.com/O5Ntvjj.png)
This is my dotfiles. Only tested in OSX and Ubuntu.

## Get this repository
```bash
# clone repository
$ cd ~
$ git clone --recursive https://github.com/cih9088/dotfiles.git ~/dotfiles

# or pull in case you have cloned already
$ cd ~/dotfiles
$ git pull
$ git submodule update --init --recursive
```

## Prerequisites
The following list would be installed in your system. You need privilege (sudo). No need if you have them on your system.
* OSX: python2, python2-pip, python3, python3-pip, wget, pbcopy, git, reattatch-to-user-namespace, xquartz
* Ubuntu: python2, python2-pip, python3, python3-pip, wget, xclip, git
```bash
$ cd ~/dotfiles
$ make prerequisitesTest    # Check what are installed and not
$ make prerequisites        # Install prerequisites (previlege is needed)
```

## How to install and update
### Variables
- `CONFIG`: making script non-interactively. Create your own config based on `config_linux.yaml` \
ex) `make install CONFIG=config_linux.yaml`
- `VERBOSE`: making script verbose \
ex) `make install VERBOSE=YES`


### one-liner
- Non-interactive init for ubuntu `cd ~/dotfiles; make init CONFIG=config_linux.yaml`
- Non-interactive init for osx `cd ~/dotfiles; make init CONFIG=config_osx.yaml`
- Interactive init `cd ~/dotfiles; make init`
- Install `cd ~/dotfiles; make install`
- Update `cd ~/dotfiles; make update`
- Only copy dotfiles `cd ~/dotfiles; make updateDotfiles`

### Install
- Install **systemwide**: others could execute those commands (**homebrew** for OSX and **apt-get** (need privilege) for Ubuntu will be used.)
- Install **locally**: others could not (All of commands would be installed in `$HOME/.local/bin`)

**NOTE**: systemwide install is prefered for osx.

```bash
$ cd ~/dotfiles
$ make init                 # includes install, update and installDev
                            # If you are new to my dotfiles, this is it. No further processes needed. 
                            # Recommended way for a newcomer.

$ make install              # Install all commands
# If you do not install dev environment, autocomplete of nvim for languages would not work at all.
$ make installDev           # Install all dev environments
```

### Update
For update configurations. \
Note that update does not update any of commands installed but dotfiles, neovimplugin, tmuxplugins, and own commands.
```bash
$ cd ~/dotfiles
$ git pull
$ git submodule update --init --recursive
$ make update               # Update all of dotfiles and configurations
```


### Advanced
#### Install
```bash
$ cd ~/dotfiles

# you could choose what to install in following list
# [installZsh, installPrezto, installNeovim, installTmux, installBins]
# For instance,
$ make installNeovim        # Install neovim only
$ make installNeovim 0.2.0  # Specify version if intended to install locally

# DEV ENVIRONMENT
# you could choose what to install in following list
# [installDevShell, installDevPython, installDevNodejs]
# For instance,
$ make installDevShell      # Install shell dev environment only
```
#### Update
```bash
$ cd ~/dotfiles
$ git pull
$ git submodule update --init --recursive

# you could choose what to update in following list
# [updateDotfiles, updateNeovimPlugins, updateTPM, updateTmuxPlugins, updateBins, updatePrezto]
# For instance,
$ make updateDotfiles       # Update dotfiles only
```

#### clean
Clean up dotfiles, configurations and folder itself.
```bash
$ cd ~/dotfiles
$ make clean        # delete installed dotfiles and folder itself (installed command remains)
```

### [initialize OSX](https://github.com/donnemartin/dev-setup#osxprepsh-script)
```bash
$ cd ~/dotfiles
$ make initOSX
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
- nohighlight: <kbd>leader</kbd> + <kbd>Space</kbd>
- toggle paste mode: <kbd>F2</kbd>
- buffers
    - new buffer: <kbd>Ctrl</kbd> + <kbd>b</kbd>
    - close buffer: <kbd>leader</kbd> + <kbd>b</kbd> + <kbd>q</kbd>
    - navigate buffer: <kbd>\]</kbd> + <kbd>b</kbd>, <kbd>\[</kbd> + <kbd>b</kbd>
    - go back to previous buffer: <kbd>Ctrl</kbd> + <kbd>w</kbd> + <kbd>Tab</kbd>
- tabs
    - new tab: <kbd>Ctrl</kbd> + <kbd>t</kbd>
    - close tab: <kbd>leader</kbd> + <kbd>t</kbd> + <kbd>q</kbd>
    - navigate tab: <kbd>\]</kbd> + <kbd>t</kbd>, <kbd>\[</kbd> + <kbd>t</kbd>
- splits
    - navigate split: <kbd>Ctrl</kbd> + [ <kbd>h</kbd>, <kbd>j</kbd>, <kbd>k</kbd>, <kbd>l</kbd> ]
    - horizontal split: <kbd>Ctrl</kbd> + <kbd>w</kbd> + <kbd>h</kbd>
    - vertical split: <kbd>Ctrl</kbd> + <kbd>w</kbd> + <kbd>v</kbd>
    - resize split: <kbd>&uparrow;</kbd>, <kbd>&downarrow;</kbd>, <kbd>&leftarrow;</kbd>, <kbd>&rightarrow;</kbd>
    - equal split: <kbd>Ctrl</kbd> + <kbd>=</kbd>
- system clipboard
    - yank to system clipboard: <kbd>leader</kbd> + <kbd>y</kbd>
    - cut to system clipboard: <kbd>leader</kbd> + <kbd>x</kbd>
    - paste from system clipboard: <kbd>leader</kbd> + <kbd>p</kbd>
- search in current visible window: `:WinSearch {args}`
- python breakpoint: <kbd>leader</kbd> + <kbd>b</kbd>
- replace a word under the curser or visually select then
    - <kbd>c</kbd> + <kbd>*</kbd>
    - repeat: <kbd>.</kbd>
    - skip: <kbd>n</kbd>
- terminal
    - open terminal horizontally: `:T`
    - open terminal vertically: `:VT`
- toggle conceal level: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>a</kbd>
- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)
    - navigate quickfix list: <kbd>\]</kbd> + <kbd>q</kbd>, <kbd>\[</kbd> + <kbd>q</kbd>
    - navigate location list: <kbd>\]</kbd> + <kbd>l</kbd>, <kbd>\[</kbd> + <kbd>l</kbd>
    - navigate SCM conflict: <kbd>\]</kbd> + <kbd>n</kbd>, <kbd>\[</kbd> + <kbd>n</kbd>
    - toggle diff: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>d</kbd>
    - toggle relativenumber: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>r</kbd>
    - toggle number: <kbd>y</kbd> + <kbd>o</kbd> + <kbd>n</kbd>
- [vim-signify](https://github.com/mhinz/vim-signify)
    - navigate hunk: <kbd>\]</kbd> + <kbd>c</kbd>, <kbd>\[</kbd> + <kbd>c</kbd>
- [vim-easyaline](https://github.com/junegunn/vim-easy-align)
- [vim-fugitive](https://github.com/tpope/vim-fugitive)
    - open Gstatus: <kbd>leader</kbd> + <kbd>G</kbd>
- [vim-easymotion](https://github.com/easymotion/vim-easymotion)
    - fast movement with two characters <kbd>s</kbd> + {char} + {char}
- [tagbar](https://github.com/majutsushi/tagbar)
    - toggle tagbar: <kbd>leader</kbd> + <kbd>T</kbd>
- [deoplete](https://github.com/Shougo/deoplete.nvim): autocompletion
    - forward: <kbd>Tab</kbd>
    - backward: <kbd>Shift</kbd> + <kbd>Tab</kbd>
- [neosnippet](https://github.com/Shougo/neosnippet.vim): snippet
    - expand or jump: <kbd>Ctrl</kbd> + <kbd>k</kbd>
    - jump: <kbd>Tab</kbd>
- [fzf](https://github.com/junegunn/fzf.vim): fuzzy finder
    - open Files: <kbd>leader</kbd> + <kbd>F</kbd>
    - open ProjectFiles: <kbd>leader</kbd> + <kbd>P</kbd>
    - open Buffers: <kbd>leader</kbd> + <kbd>B</kbd>
    - open History: <kbd>leader</kbd> + <kbd>H</kbd>
    - open Commits: <kbd>leader</kbd> + <kbd>C</kbd>
    - open Blines: <kbd>leader</kbd> + <kbd>L</kbd>
    - open MRU: <kbd>leader</kbd> + <kbd>M</kbd>
- [vim-startify](https://github.com/mhinz/vim-startify): nice start
    - open startify: <kbd>leader</kbd> + <kbd>S</kbd>
- [ctrlsf](https://github.com/dyng/ctrlsf.vim): powerful search
    - search prompt: <kbd>Ctrl</kbd> + <kbd>f</kbd> + <kbd>f</kbd>
- [vim-sandwich](https://github.com/machakann/vim-sandwich): easy surrounding modification
    - add surrounding: <kbd>s</kbd> + <kbd>a</kbd> + {motion/text object} + {addition}
    - delete surrounding: <kbd>s</kbd> + <kbd>d</kbd> + {deletion}
    - replace surrounding: <kbd>s</kbd> + <kbd>r</kbd> + {deletion} + {addition}
- [vim-dirvish](https://github.com/justinmk/vim-dirvish): file explore
    - open dirvish: <kbd>-</kbd>
    - reload: <kbd>g</kbd> + <kbd>r</kbd>
    - go to home: <kbd>g</kbd> + <kbd>~</kbd>
    - hide hiddden files: <kbd>g</kbd> + <kbd>h</kbd>
- [vim-rooter](https://github.com/airblade/vim-rooter): change pwd to project root. usefule with fzf
    - run rooter: <kbd>leader</kbd> + <kbd>R</kbd>
- [nerdcommenter](https://github.com/scrooloose/nerdcommenter): Comment out easily
    - toggle comment: <kbd>leader</kbd> + <kbd>c</kbd> + <kbd>Space</kbd>
    - invert comment: <kbd>leader</kbd> + <kbd>c</kbd> + <kbd>i</kbd>
    - yank and comment: <kbd>leader</kbd> + <kbd>c</kbd> + <kbd>y</kbd>
- [auto-pair](https://github.com/jiangmiao/auto-pairs)
    - insert parens purely: <kbd>Ctrl</kbd> + <kbd>v</kbd> + {paren}
- [NrrwRgn](https://github.com/chrisbra/NrrwRgn)
    - open selected visual block as narrowed window: <kbd>leader</kbd> + <kbd>n</kbd> + <kbd>r</kbd>
- [splitjoin](https://github.com/AndrewRadev/splitjoin.vim)
    - split one-liner into multiple lines: <kbd>g</kbd> + <kbd>S</kbd>
    - join a block into single-line statement: <kbd>g</kbd> + <kbd>J</kbd>

### [tmux](https://github.com/tmux/tmux)
For more detailed information please refer [tmux.conf](https://github.com/cih9088/dotfiles/blob/master/tmux/tmux.conf)
- prefix: <kbd>Ctrl</kbd> + <kbd>a</kbd>
- detach: <kbd>prefix</kbd> + <kbd>d</kbd>
- reload config file: <kbd>prefix</kbd> + <kbd>r</kbd>
- go to pane with fzf: <kbd>prefix</kbd> + <kbd>0</kbd>
- window
    - create new window: <kbd>prefix</kbd> + <kbd>c</kbd>
	- kill current window: <kbd>prefix</kbd> + <kbd>X</kbd>
    - navigate window: <kbd>prefix</kbd> + [ <kbd>1</kbd>, ..., <kbd>9</kbd> ]
    - navigate window alternatively: <kbd>prefix</kbd> + <kbd>'</kbd> + {window index}
    - rename window: <kbd>prefix</kbd> + <kbd>,</kbd>
    - swap current window: <kbd>prefix</kbd> + [ <kbd>\<</kbd>, <kbd>\></kbd> ]
- pane
    - split current pane vertically: <kbd>prefix</kbd> + <kbd>v</kbd>
    - split current pane horizontally: <kbd>prefix</kbd> + <kbd>h</kbd>
    - kill current pane: <kbd>prefix</kbd> + <kbd>x</kbd>
    - navigate pane: <kbd>prefix</kbd> + [ <kbd>h</kbd>, <kbd>j</kbd>, <kbd>k</kbd>, <kbd>l</kbd> ]
    - resize pane: <kbd>prefix</kbd> + [ <kbd>H</kbd>, <kbd>J</kbd>, <kbd>K</kbd>, <kbd>L</kbd> ]
    - swap current pane: <kbd>prefix</kbd> + [ <kbd>[</kbd>, <kbd>]</kbd> ]
- copy mode
    - enter copy mode: <kbd>prefix</kbd> + <kbd>enter</kbd>
    - select region: <kbd>v</kbd>
    - copy selected region: <kbd>y</kbd>
    - append selected region to clipboard: <kbd>A</kbd>
    - copy current line: <kbd>Y</kbd>
    - copy from the cursor to the end of the line: <kbd>D</kbd>
- toggle
    - synchronizing mode: <kbd>prefix</kbd> + <kbd>e</kbd>
    - mouse mode: <kbd>prefix</kbd> + <kbd>m</kbd>
    - maximizing pane: <kbd>prefix</kbd> + <kbd>z</kbd>
    - disable tmux: <kbd>F12</kbd> (useful in nested tmux)
- [tmux-resurrect](https://github.com/cih9088/tmux-resurrect)
    - save tmux environment: <kbd>prefix</kbd> + <kbd>Ctrl</kbd> + <kbd>s</kbd>
    - restore tmux environment: <kbd>prefix</kbd> + <kbd>Ctrl</kbd> + <kbd>r</kbd>
<!-- - renew environment variables (e.g. DISPLAY): <kbd>prefix</kbd> + <kbd>\$</kbd> -->

## Issues
1. ~~Showing following error message at the top of terminal when the zsh 5.5 +  started \
    `/var/folders/vp/15xrzrrj4sx0dd3k6gsv1hmw0000gn/T//prezto-fasd-cache.501.zsh:compctl:17: unknown condition code:`~~ \
    -> [it is now fixed with zsh 5.6.1 + ](https://github.com/sorin-ionescu/prezto/issues/1569)
2. Showing abnormal font like below image \
-> [nerd font](https://github.com/ryanoasis/nerd-fonts) patched font is needed or change `g:lightline#bufferline#enable_devcons` to 0 in `.vimrc` \
![abnormal font](https://imgur.com/wSb49GM.png)

## TODO
- the fuck version
- duplicated which
