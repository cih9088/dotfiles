function gpu
    set -l gpus $argv[1]
    set --erase argv[1]
    if test (count "$argv") -eq 0 > /dev/null
        echo "No command provided" >&2; return 1
    end
    if string match -r '^[0-9-]+$' $gpus > /dev/null
        set -l count ( string length $gpus )
        if test "$gpus" = "-"
            set gpus ""
        else if test "{$count} > 1"
            set gpus ( echo $gpus | fold -w 1 | paste -sd',' - )
        end
        env CUDA_VISIBLE_DEVICES="$gpus" command $argv
    else
        echo "Not a valid gpu index" >&2; return 1
    end
end
