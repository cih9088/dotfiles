function full-cmd
    cat /proc/"$1"/cmdline | tr '\000' ' '
end
