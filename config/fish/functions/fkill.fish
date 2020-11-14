function fkill
    if ! [ -x ( command -v fzf ) ]
        echo "fzf is not found" >&2
        return
    end

    if [ ( count $argv ) -eq 0 ]
        set signal 9
    else if [ ( count $argv ) -eq 1 ]
        set signal $argv[1]
        if ! string match -r '^[0-9]+$' $gpus > /dev/null
            echo "Not a valid signal" >&2; return 1
        end
    else
        echo 'Only one signal is possible' >&2; return 1
    end

    if [ ( id -u ) != "0" ]
        set kill_pids (ps -f -u ( id -u ) | sed 1d | fzf -m --height=50% --cycle --preview 'echo {}' --preview-window down:5:wrap | awk '{print $2}')
    else
        set kill_pids (ps -ef | sed 1d | fzf -m --height=50% --cycle --preview 'echo {}' --preview-window down:5:wrap | awk '{print $2}')
    end

    if [ "x$kill_pids" != "x" ]
        echo $kill_pids | xargs kill -$signal
    end
end
