function cd
    if count {$argv} > /dev/null
        builtin cd "$argv"
    else
        builtin cd {$HOME}
    end

    set -l n_files (timeout 0.01 ls -f | wc -l)

    if [ {$n_files} -ne 0 ]
        set -l lines ( tput lines )
        set -l cols ( tput cols )
        set -l term_size ( math " $lines * $cols / 100" )
        if test "{$n_files} < {$term_size}"
            ls
        end
    end
end
