
#   ======================================================================================
#   ENVIRONMENT CONFIGURATION
#   ======================================================================================


#   Identify platform
#   --------------------------------------------------------------------------------------
    switch (uname)
        case Linux
            set -x platform "LINUX"
        case Darwin
            set -x platform "OSX"
        case FreeBSD NetBSD DragonFly
            set -x platform "FreeBSD"
        case \*
            set -x platform "unknown: ( uname )"
    end


#   User's private bin directory
#   --------------------------------------------------------------------------------------
    set -x PATH $HOME/.local/bin $PATH


# #   yarn to PATH
# #   --------------------------------------------------------------------------------------
#     set -x PATH $HOME/.yan/bin $PATH
#     set -x PATH $HOME/.config/yarn/global/node_modules/.bin $PATH


#   virtualenvwrapper (using system python)
#   --------------------------------------------------------------------------------------
    set -x WORKON_HOME $HOME/.virtualenvs
    set -x PROJECT_HOME $HOME/workspace
    # Inside tmux session, these environment variables are changed
    # because of the change of PATH during zsh initialisation in non-tmux session
    # This prevents no module found error in virtualenvwrapper
    [ -z "$TMUX" ] && set -x VIRTUALENVWRAPPER_PYTHON (which python)
    [ -z "$TMUX" ] && set -x VIRTUALENVWRAPPER_VIRTUALENV (which virtualenv)
    [ -z "$TMUX" ] && set -x VIRTUALENVWRAPPER_SCRIPT (which virtualenvwrapper.sh)
    [ -z "$TMUX" ] && set -x VIRTUALENVWRAPPER_LAZY_SCRIPT (which virtualenvwrapper_lazy.sh)
    # set -x VIRTUALENVWRAPPER_VIRTUALENV_ARGS '--system-site-packages'
    # set -x VIRTUALENVWRAPPER_VIRTUALENV_ARGS '--no-site-packages'


#   Setup default blocksize for ls, df, du
#   from this: http://hints.macworld.com/comment.php?mode=view&cid=24491
#   --------------------------------------------------------------------------------------
    set -x BLOCKSIZE 1k


#   Add color to terminal
#   (this is all commented out as I use Mac Terminal Profiles)
#   from http://osxdaily.com/2012/02/21/add-color-to-the-terminal-in-mac-os-x/
#   --------------------------------------------------------------------------------------
   set -x LS_COLORS "no=00:fi=00:di=36:ln=35:pi=30;44:so=35;44:do=35;44:bd=33;44:cd=37;44:or=05;37;41:mi=05;37;41:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.bat=01;31:*.reg=01;31:*.app=01;31:*.txt=32:*.org=32:*.md=32:*.mkd=32:*.h=32:*.c=32:*.C=32:*.cc=32:*.cpp=32:*.cxx=32:*.objc=32:*.cl=32:*.sh=32:*.bash=32:*.csh=32:*.zsh=32:*.el=32:*.vim=32:*.java=32:*.pl=32:*.pm=32:*.py=32:*.rb=32:*.hs=32:*.php=32:*.htm=32:*.html=32:*.shtml=32:*.erb=32:*.haml=32:*.xml=32:*.rdf=32:*.css=32:*.sass=32:*.scss=32:*.less=32:*.js=32:*.coffee=32:*.man=32:*.0=32:*.1=32:*.2=32:*.3=32:*.4=32:*.5=32:*.6=32:*.7=32:*.8=32:*.9=32:*.l=32:*.n=32:*.p=32:*.pod=32:*.tex=32:*.go=32:*.sql=32:*.bmp=33:*.cgm=33:*.dl=33:*.dvi=33:*.emf=33:*.eps=33:*.gif=33:*.jpeg=33:*.jpg=33:*.JPG=33:*.mng=33:*.pbm=33:*.pcx=33:*.pdf=33:*.pgm=33:*.png=33:*.PNG=33:*.ppm=33:*.pps=33:*.ppsx=33:*.ps=33:*.svg=33:*.svgz=33:*.tga=33:*.tif=33:*.tiff=33:*.xbm=33:*.xcf=33:*.xpm=33:*.xwd=33:*.xwd=33:*.yuv=33:*.aac=33:*.au=33:*.flac=33:*.m4a=33:*.mid=33:*.midi=33:*.mka=33:*.mp3=33:*.mpa=33:*.mpeg=33:*.mpg=33:*.ogg=33:*.ra=33:*.wav=33:*.anx=33:*.asf=33:*.avi=33:*.axv=33:*.flc=33:*.fli=33:*.flv=33:*.gl=33:*.m2v=33:*.m4v=33:*.mkv=33:*.mov=33:*.MOV=33:*.mp4=33:*.mp4v=33:*.mpeg=33:*.mpg=33:*.nuv=33:*.ogm=33:*.ogv=33:*.ogx=33:*.qt=33:*.rm=33:*.rmvb=33:*.swf=33:*.vob=33:*.webm=33:*.wmv=33:*.doc=31:*.docx=31:*.rtf=31:*.odt=31:*.dot=31:*.dotx=31:*.ott=31:*.xls=31:*.xlsx=31:*.ods=31:*.ots=31:*.ppt=31:*.pptx=31:*.odp=31:*.otp=31:*.fla=31:*.psd=31:*.7z=1;35:*.apk=1;35:*.arj=1;35:*.bin=1;35:*.bz=1;35:*.bz2=1;35:*.cab=1;35:*.deb=1;35:*.dmg=1;35:*.gem=1;35:*.gz=1;35:*.iso=1;35:*.jar=1;35:*.msi=1;35:*.rar=1;35:*.rpm=1;35:*.tar=1;35:*.tbz=1;35:*.tbz2=1;35:*.tgz=1;35:*.tx=1;35:*.war=1;35:*.xpi=1;35:*.xz=1;35:*.z=1;35:*.Z=1;35:*.zip=1;35:*.ANSI-30-black=30:*.ANSI-01;30-brblack=01;30:*.ANSI-31-red=31:*.ANSI-01;31-brred=01;31:*.ANSI-32-green=32:*.ANSI-01;32-brgreen=01;32:*.ANSI-33-yellow=33:*.ANSI-01;33-bryellow=01;33:*.ANSI-34-blue=34:*.ANSI-01;34-brblue=01;34:*.ANSI-35-magenta=35:*.ANSI-01;35-brmagenta=01;35:*.ANSI-36-cyan=36:*.ANSI-01;36-brcyan=01;36:*.ANSI-37-white=37:*.ANSI-01;37-brwhite=01;37:*.log=01;34:*~=01;34:*#=01;34:*.bak=01;36:*.BAK=01;36:*.old=01;36:*.OLD=01;36:*.org_archive=01;36:*.off=01;36:*.OFF=01;36:*.dist=01;36:*.DIST=01;36:*.orig=01;36:*.ORIG=01;36:*.swp=01;36:*.swo=01;36:*,v=01;36:*.gpg=34:*.gpg=34:*.pgp=34:*.asc=34:*.3des=34:*.aes=34:*.enc=34:*.sqlite=34:"


#   CUDA enviroment variables
#   ------------------------------------------------------------------------------------
    if [ $platform = "LINUX" ]
        set -x CUDA_DEVICE_ORDER PCI_BUS_ID
        set -x CUDA_HOME /usr/local/cuda
        set -x PATH $CUDA_HOME/bin PATH

        # CUDA toolkit >= 9.0
        set -x LD_LIBRARY_PATH $CUDA_HOME/lib64 $LD_LIBRARY_PATH
        set -x LD_LIBRARY_PATH $CUDA_HOME/extras/CUPTI/lib64 $LD_LIBRARY_PATH
    end


#   Setup FZF
#   --------------------------------------------------------------------------------------
    if [ -x ( command -v fd ) ]
        set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    end
    set -x FZF_ALT_C_OPTS "--preview 'tree -C {} | head -200'"
    set -x FZF_CTRL_T_OPTS "--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    # set -x FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    set -x FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:5:wrap"


#   Setup xpanes
#   --------------------------------------------------------------------------------------
    set -x TMUX_XPANES_PANE_BORDER_FORMAT '#[bg=colour238] #[bg=colour239] #[bg=colour240]#T#[bg=colour239] #[bg=colour238] #[default]'

#   Set thefuck
#   --------------------------------------------------------------------------------------
    [ -x ( command -v thefuck ) ] && thefuck --alias | source

#   Set FZF
#   --------------------------------------------------------------------------------------
    [ -f $HOME/.fzf/bin/fzf ] && set -x PATH $HOME/.fzf/bin $PATH




#   ======================================================================================
#   2.  MAKE TERMINAL BETTER
#   ======================================================================================


#   Set alias
#   --------------------------------------------------------------------------------------
    set -l _rsync_cmd "rsync --verbose --progress --human-readable --compress --archive \
    --hard-links --one-file-system"
    alias rsync-copy="$_rsync_cmd"
    alias rsync-move="$_rsync_cmd --remove-source-files"
    alias rsync-update="$_rsync_cmd --update"
    alias rsync-synchronize="$_rsync_cmd --update --delete"
    alias rsync-copy-sum="rsync-copy --info=progress2,name0"
    alias rsync-move-sum="rsync-move --info=progress2,name0"

    if [ $platform = "OSX" ]
        alias f='open -a Finder ./'                             # f:            Opens current directory in MacOS Finder
        alias DT='tee ~/Desktop/terminalOut.txt'                # DT:           Pipe content to file on MacOS Desktop
    else if [ $platform = "LINUX" ]
        alias clear-swap="sudo sh -c 'swapoff -a && swapon -a'" # clear-swap:   clear swap memory
    end
    alias e='$VISUAL'
    alias c='clear'                                     # c:            Clear terminal display
    alias path='printf "%s\n" $PATH'                 # path:         Echo all executable Paths
    alias fix-stty='stty sane'                          # fix_stty:     Restore terminal settings when screwed up
    alias color256='curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash'

    alias cp='cp -iv'                           # Preferred 'cp' implementation
    alias mv='mv -iv'                           # Preferred 'mv' implementation
    alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
    alias rm='rm -iv'

    alias http-serve='python3 -m http.server'

    alias myip='dig myip.opendns.com @resolver1.opendns.com +short' # myip:         Public facing IP Address
    alias flushDNS='dscacheutil -flushcache'                        # flushDNS:     Flush out the DNS Cache
    alias lsock='sudo lsof -i -P'                                   # lsock:        Display open sockets
    alias lsockU='sudo lsof -nP | grep UDP'                         # lsockU:       Display only open UDP sockets
    alias lsockT='sudo lsof -nP | grep TCP'                         # lsockT:       Display only open TCP sockets
    alias ipInfo0='ipconfig getpacket en0'                          # ipInfo0:      Get info on connections for en0
    alias ipInfo1='ipconfig getpacket en1'                          # ipInfo1:      Get info on connections for en1
    alias openPorts='sudo lsof -i -P | grep -i "listen"'            # openPorts:    All listening connections
    alias showBlocked='sudo ipfw list'                              # showBlocked:  All ipfw rules inc/ blocked IPs

    function mcd
        mkdir -p "$argv" && cd "$argv"
    end

    if [ $platform = "OSX" ]
        function trash
            command mv "$argv" ~/.Trash        # trash:        Moves a file to the MacOS trash
        end
        function ql        # ql:           Opens any file in MacOS Quicklook Preview
            qlmanage -p "$argv" >& /dev/null;
        end
    end


#   update environment in tmux just before every command
#   --------------------------------------------------------------------------------------
    # if [ -n "$TMUX" ]
    #     function refresh
    #         tmux showenv -s DISPLAY | source
    #         tmux showenv -s SSH_AUTH_SOCK | source
    #     end
    # else
    #     function refresh
    #         :
    #     end
    # end
    # function preexec --on-event fish_preexec
    #     refresh
    # end
