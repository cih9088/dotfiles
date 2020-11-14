function ssh
    if ! [ -x ( command -v xpanes ) ]
        command ssh $argv
    else
        if [ ( count $argv ) -eq 0 ]
            set -l hosts ( cat $HOME/.ssh/config \
            | awk '$1=="Host"{print $2}' \
            | grep -v '*' )
            set -l _status $status
            [ $_status -ne 0 ] && return $_status
            set -l hosts ( echo $hosts | tr ' ' '\n' \
            | fzf --multi --height=30% --cycle --no-sort --layout=reverse \
            --preview-window=down:2 \
            --preview='cat $HOME/.ssh/config | grep Host | awk -v host={} '"'"'$0~host{getline;gsub(/^[ \t]+/,"", $0);print;getline; if ($0 ~ /HostName/) {;gsub(/^[ \t]+/,"", $0);print;}}'"'" )
            if ! [ -z "$hosts" ]
                echo $hosts | tr ' ' '\n' | xpanes -t -s -c "ssh {}"
            end
        else
            if ps -p $fish_pid -o ppid= \
                | xargs -I{} ps -p {} -o comm= \
                | grep -qw tmux
            # Note: Options without parameter were hardcoded,
            # in order to distinguish an option's parameter from the destination.
            #
            #                   s/[[:space:]]*\(\( | spaces before options
            #     \(-[46AaCfGgKkMNnqsTtVvXxYy]\)\| | option without parameter
            #                     \(-[^[:space:]]* | option
            # \([[:space:]]\+[^[:space:]]*\)\?\)\) | parameter
            #                      [[:space:]]*\)* | spaces between options
            #                        [[:space:]]\+ | spaces before destination
            #                \([^-][^[:space:]]*\) | destination
            #                                   .* | command
            #                                 /\6/ | replace with destination
            # tmux set-option -p pane-border-format '#[bg=colour239] #[bg=colour240]#T#[bg=colour239] #[default]'
            tmux select-pane -T ( echo "$argv" \
              | sed 's/[[:space:]]*\(\(\(-[46AaCfGgKkMNnqsTtVvXxYy]\)\|\(-[^[:space:]]*\([[:space:]]\+[^[:space:]]*\)\?\)\)[[:space:]]*\)*[[:space:]]\+\([^-][^[:space:]]*\).*/\6/' )
            end
            command ssh $argv
        end
    end
end
