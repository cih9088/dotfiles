function tm
    if ! [ -x ( command -v tmux ) ]
        echo "tmux is not found" >&2
        return
    end
    if tmux ls > /dev/null 2>&1
        set -q TMUX && set change "switch-client" || set change "attach-session"
        if [ ( count $argv ) -eq 1 ] > /dev/null
            tmux $change -t $argv[1] 2>/dev/null
            if [ $status -ne 0 ]
                tmux new-session -d -s $argv[1] && tmux $change -t $argv[1]
                return
            end
        end
        tmux list-session -F "#{session_name}" 2>/dev/null | fzf --select-1 --exit-0 | read -l session
        tmux $change -t $session || echo "No session found"
    else
        tmux
    end
end

