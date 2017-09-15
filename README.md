# dotfiles
This is my dot files.
The only thing that did not verified yet is **installation of tmux**

## Get this repository
```
cd ~
git clone https://github.com/cih9088/dotfiles.git ~/dotfiles
cd dotfiles
```

## For MAC
Install brew first
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

## Installation of Prezto
1. Install zsh
    ```
    sudo apt-get install zsh
    ```
    ```
    brew install zsh
    ```

2. Launch zsh
    ```
    zsh
    ```
3. Run prezto_setup.sh
    ```
    ./prezto_setup.sh
    ```
4. (Optional) Set Zsh as your default shell
    ```
    chsh -s /bin/zsh
    ```

## Installation of tmux
1. Run tmux_setup.sh
    ```
    ./tmux_setup.sh
    ```

## Copy dot files
1. Run dot_setup.sh
    ```
    ./dot_setup.sh
    ```

## Post setup [only for ubuntu]
1. Run post_setup.sh
    ```
    ./post_setup.sh
    ```
