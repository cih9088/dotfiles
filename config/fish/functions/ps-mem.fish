function ps-mem
    if [ $PLATFORM = "OSX" ]
        set cmd 'ps -m -axo user,pid,ppid,pcpu,pmem,state,time,command'
    else if [ $PLATFORM = "LINUX" ]
        set cmd 'ps --sort -rss -axo user,pid,ppid,pcpu,pmem,nlwp,state,time,command'
    else
        echo "$t PLATFORM is not supported" >&2
        return 1
    end
    eval $cmd | head -n 16 | cut -c -80
end
